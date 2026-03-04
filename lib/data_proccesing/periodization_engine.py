from datetime import date, timedelta
from typing import Optional
from .models import (
    MetricasFatiga, IndiceRiesgo, PlanSemanal,
    FasePeriodizacion, NivelFatiga, ZonaRiesgo
)


PARAMETROS_FASE = {
    FasePeriodizacion.ACUMULACION:     (1.20, 0.75, 5),
    FasePeriodizacion.INTENSIFICACION: (0.85, 1.15, 4),
    FasePeriodizacion.REALIZACION:     (0.60, 1.25, 3),
    FasePeriodizacion.DESCARGA:        (0.50, 0.65, 2),
}

EJERCICIOS_POR_FASE = {
    FasePeriodizacion.ACUMULACION: [
        "Sentadilla con barra (5×8 @RPE 7)",
        "Press de banca (4×10 @RPE 6)",
        "Peso muerto rumano (4×10 @RPE 6)",
        "Remo con barra (4×8 @RPE 7)",
        "Zancadas con mancuernas (3×12 @RPE 6)",
    ],
    FasePeriodizacion.INTENSIFICACION: [
        "Sentadilla con barra (5×3 @RPE 9)",
        "Press de banca (4×4 @RPE 9)",
        "Peso muerto convencional (3×3 @RPE 9)",
        "Press militar (4×5 @RPE 8)",
        "Pull-up lastrado (4×5 @RPE 8)",
    ],
    FasePeriodizacion.REALIZACION: [
        "Sentadilla (3×2 @RPE 10 — máximo)",
        "Press de banca (3×2 @RPE 10)",
        "Peso muerto (2×1 @RPE 10)",
        "Activación neural ligera (2×3 @RPE 7)",
    ],
    FasePeriodizacion.DESCARGA: [
        "Sentadilla goblet (3×10 @RPE 5)",
        "Press mancuernas (3×12 @RPE 5)",
        "Peso muerto rumano ligero (3×12 @RPE 5)",
        "Movilidad y estiramiento activo",
        "Cardio suave 20-30 min",
    ],
}


def detectar_fase_automatica(
    metricas_fatiga: MetricasFatiga,
    indice_riesgo: IndiceRiesgo,
    semanas_desde_inicio: int = 0
) -> FasePeriodizacion:
    if (indice_riesgo.zona == ZonaRiesgo.ROJA or
            metricas_fatiga.nivel_fatiga == NivelFatiga.SOBREENTRENADO):
        return FasePeriodizacion.DESCARGA

    if indice_riesgo.score > 0.65:
        return FasePeriodizacion.DESCARGA

    if (metricas_fatiga.nivel_fatiga == NivelFatiga.FRESCO and
            metricas_fatiga.ctl > 50 and
            indice_riesgo.zona == ZonaRiesgo.VERDE):
        return FasePeriodizacion.REALIZACION

    if (metricas_fatiga.nivel_fatiga == NivelFatiga.OPTIMO and
            metricas_fatiga.acwr <= 1.2):
        return FasePeriodizacion.INTENSIFICACION

    ciclo = semanas_desde_inicio % 4
    mapa_ciclo = {
        0: FasePeriodizacion.ACUMULACION,
        1: FasePeriodizacion.ACUMULACION,
        2: FasePeriodizacion.INTENSIFICACION,
        3: FasePeriodizacion.DESCARGA,
    }
    return mapa_ciclo[ciclo]


def ajustar_volumen(
    volumen_base: float,
    metricas_fatiga: MetricasFatiga,
    indice_riesgo: IndiceRiesgo
) -> float:
    ajuste = 0.0

    if indice_riesgo.zona == ZonaRiesgo.ROJA:
        ajuste -= 0.30
    elif indice_riesgo.zona == ZonaRiesgo.AMARILLA:
        ajuste -= 0.15

    if metricas_fatiga.acwr > 1.3:
        ajuste -= 0.10

    if metricas_fatiga.tsb < -20:
        ajuste -= 0.10
    elif metricas_fatiga.tsb > 10:
        ajuste += 0.05

    resultado = round(max(0.30, min(1.50, volumen_base + ajuste)), 2)
    return resultado


def ajustar_intensidad(
    intensidad_base: float,
    metricas_fatiga: MetricasFatiga,
    indice_riesgo: IndiceRiesgo
) -> float:
    ajuste = 0.0

    if metricas_fatiga.nivel_fatiga == NivelFatiga.SOBREENTRENADO:
        ajuste -= 0.25
    elif metricas_fatiga.nivel_fatiga == NivelFatiga.FATIGADO:
        ajuste -= 0.10
    elif metricas_fatiga.nivel_fatiga == NivelFatiga.FRESCO:
        ajuste += 0.05

    if indice_riesgo.zona == ZonaRiesgo.ROJA:
        ajuste -= 0.15

    if metricas_fatiga.acwr > 1.5:
        ajuste -= 0.10

    resultado = round(max(0.40, min(1.30, intensidad_base + ajuste)), 2)
    return resultado


def ajustar_sesiones_semana(
    sesiones_base: int,
    metricas_fatiga: MetricasFatiga,
    indice_riesgo: IndiceRiesgo
) -> int:
    ajuste = 0

    if indice_riesgo.zona == ZonaRiesgo.ROJA:
        ajuste -= 2
    elif indice_riesgo.zona == ZonaRiesgo.AMARILLA:
        ajuste -= 1

    if metricas_fatiga.nivel_fatiga == NivelFatiga.SOBREENTRENADO:
        ajuste -= 2
    elif metricas_fatiga.nivel_fatiga == NivelFatiga.FRESCO:
        ajuste += 1

    return max(1, min(6, sesiones_base + ajuste))


def generar_notas_plan(
    fase: FasePeriodizacion,
    metricas_fatiga: MetricasFatiga,
    indice_riesgo: IndiceRiesgo,
    volumen_ajustado: float,
    intensidad_ajustada: float
) -> str:
    notas = [
        f"📊 Fase: {fase.value.upper()}",
        f"ACWR actual: {metricas_fatiga.acwr:.2f} | TSB: {metricas_fatiga.tsb:.1f}",
        f"Zona de riesgo: {indice_riesgo.zona.value} (score: {indice_riesgo.score:.2f})",
        f"Volumen relativo: {volumen_ajustado:.0%} | Intensidad relativa: {intensidad_ajustada:.0%}",
    ]

    if fase == FasePeriodizacion.DESCARGA:
        notas.append(
            "🔄 Semana de descarga activa. Prioriza recuperación. "
            "No añadas volumen extra aunque te sientas bien."
        )
    elif fase == FasePeriodizacion.REALIZACION:
        notas.append(
            "🏆 Semana de pico. Reduce volumen y maximiza descanso. "
            "Evalúa marcas personales al final de la semana."
        )
    elif fase == FasePeriodizacion.INTENSIFICACION:
        notas.append(
            "💪 Semana de intensificación. Enfócate en calidad sobre cantidad. "
            "Respeta los períodos de calentamiento."
        )
    else:
        notas.append(
            "📈 Semana de acumulación. Construye base de volumen. "
            "Incrementos de carga no deben superar el 10% semanal."
        )

    return "\n".join(notas)


def generar_plan_semanal(
    usuario_id: str,
    metricas_fatiga: MetricasFatiga,
    indice_riesgo: IndiceRiesgo,
    semana_inicio: Optional[date] = None,
    semanas_desde_inicio: int = 0,
    fase_override: Optional[FasePeriodizacion] = None
) -> PlanSemanal:
    if semana_inicio is None:
        hoy = date.today()
        dias_hasta_lunes = (7 - hoy.weekday()) % 7 or 7
        semana_inicio = hoy + timedelta(days=dias_hasta_lunes)

    fase = fase_override or detectar_fase_automatica(
        metricas_fatiga, indice_riesgo, semanas_desde_inicio
    )

    vol_base, int_base, ses_base = PARAMETROS_FASE[fase]

    volumen = ajustar_volumen(vol_base, metricas_fatiga, indice_riesgo)
    intensidad = ajustar_intensidad(int_base, metricas_fatiga, indice_riesgo)
    sesiones = ajustar_sesiones_semana(ses_base, metricas_fatiga, indice_riesgo)

    ejercicios = EJERCICIOS_POR_FASE[fase]

    notas = generar_notas_plan(fase, metricas_fatiga, indice_riesgo, volumen, intensidad)

    return PlanSemanal(
        usuario_id=usuario_id,
        semana_inicio=semana_inicio,
        fase=fase,
        sesiones_recomendadas=sesiones,
        volumen_relativo=volumen,
        intensidad_relativa=intensidad,
        ejercicios_sugeridos=ejercicios,
        notas_entrenador=notas,
    )


def proyectar_planes_macrociclo(
    usuario_id: str,
    metricas_fatiga_inicial: MetricasFatiga,
    indice_riesgo_inicial: IndiceRiesgo,
    num_semanas: int = 12
) -> list[PlanSemanal]:
    planes = []
    hoy = date.today()
    dias_hasta_lunes = (7 - hoy.weekday()) % 7 or 7
    primer_lunes = hoy + timedelta(days=dias_hasta_lunes)

    for semana in range(num_semanas):
        semana_inicio = primer_lunes + timedelta(weeks=semana)

        plan = generar_plan_semanal(
            usuario_id=usuario_id,
            metricas_fatiga=metricas_fatiga_inicial,
            indice_riesgo=indice_riesgo_inicial,
            semana_inicio=semana_inicio,
            semanas_desde_inicio=semana,
        )
        planes.append(plan)

    return planes