from datetime import date, timedelta
from typing import Optional
from .models import (
    IndiceRiesgo, MetricasFatiga, SesionEntrenamiento, ZonaRiesgo
)
from .fatigue_engine import (
    calcular_metricas_fatiga,
    construir_mapa_cargas,
    obtener_cargas_rango,
)


PESOS_RIESGO = {
    "acwr":           0.35,
    "tsb":            0.25,
    "spike_carga":    0.20,
    "sueno":          0.10,
    "frecuencia_c":   0.05,
    "dias_sin_desc":  0.05,
}


def factor_riesgo_acwr(acwr: float) -> float:
    if acwr <= 0.0:
        return 0.5

    if acwr < 0.8:
        return round(0.40 - (acwr / 0.8) * 0.25, 3)

    if acwr <= 1.3:
        proporcion = (acwr - 0.8) / 0.5
        return round(proporcion * 0.15, 3)

    if acwr <= 1.5:
        proporcion = (acwr - 1.3) / 0.2
        return round(0.15 + proporcion * 0.45, 3)

    proporcion = min((acwr - 1.5) / 1.0, 1.0)
    return round(0.60 + proporcion * 0.40, 3)


def factor_riesgo_tsb(tsb: float) -> float:
    if tsb > 10:
        return 0.05

    if tsb >= 0:
        proporcion = 1 - (tsb / 10)
        return round(0.05 + proporcion * 0.10, 3)

    if tsb >= -10:
        proporcion = abs(tsb) / 10
        return round(0.15 + proporcion * 0.15, 3)

    if tsb >= -30:
        proporcion = (abs(tsb) - 10) / 20
        return round(0.30 + proporcion * 0.45, 3)

    proporcion = min((abs(tsb) - 30) / 20, 1.0)
    return round(0.75 + proporcion * 0.25, 3)


def factor_riesgo_spike_carga(
    mapa_cargas: dict[date, float],
    fecha_referencia: date,
    umbral_spike: float = 0.30
) -> float:
    semana_actual_inicio = fecha_referencia - timedelta(days=6)
    semana_anterior_inicio = fecha_referencia - timedelta(days=13)
    semana_anterior_fin = fecha_referencia - timedelta(days=7)

    carga_actual = sum(obtener_cargas_rango(
        mapa_cargas, semana_actual_inicio, fecha_referencia
    ))
    carga_anterior = sum(obtener_cargas_rango(
        mapa_cargas, semana_anterior_inicio, semana_anterior_fin
    ))

    if carga_anterior == 0.0:
        return 0.20

    incremento = (carga_actual - carga_anterior) / carga_anterior

    if incremento <= umbral_spike:
        return round(max(0.0, incremento / umbral_spike * 0.15), 3)

    exceso = (incremento - umbral_spike) / (1.0 - umbral_spike)
    return round(0.15 + min(exceso, 1.0) * 0.85, 3)


def factor_riesgo_sueno(sesiones_recientes: list[SesionEntrenamiento]) -> float:
    horas_con_datos = [
        s.horas_sueno for s in sesiones_recientes
        if s.horas_sueno is not None
    ]

    if not horas_con_datos:
        return 0.10

    promedio_sueno = sum(horas_con_datos) / len(horas_con_datos)

    if promedio_sueno >= 8:
        return 0.0
    elif promedio_sueno >= 7:
        return 0.10
    elif promedio_sueno >= 6:
        return 0.25
    elif promedio_sueno >= 5:
        return 0.55
    else:
        return 0.90


def factor_riesgo_frecuencia_cardiaca(
    sesiones_recientes: list[SesionEntrenamiento]
) -> float:
    fc_datos = [
        s.frecuencia_cardiaca_promedio for s in sesiones_recientes
        if s.frecuencia_cardiaca_promedio is not None
    ]

    if not fc_datos:
        return 0.0

    fc_promedio = sum(fc_datos) / len(fc_datos)

    if fc_promedio < 130:
        return 0.05
    elif fc_promedio < 150:
        return 0.15
    elif fc_promedio < 165:
        return 0.35
    elif fc_promedio < 180:
        return 0.60
    else:
        return 0.85


def factor_riesgo_dias_consecutivos(
    mapa_cargas: dict[date, float],
    fecha_referencia: date
) -> float:
    dias_consecutivos = 0
    fecha_check = fecha_referencia

    while True:
        if mapa_cargas.get(fecha_check, 0.0) > 0:
            dias_consecutivos += 1
            fecha_check -= timedelta(days=1)
        else:
            break

        if dias_consecutivos >= 14:
            break

    if dias_consecutivos <= 3:
        return 0.0
    elif dias_consecutivos <= 5:
        return round((dias_consecutivos - 3) / 2 * 0.25, 3)
    elif dias_consecutivos <= 7:
        return round(0.25 + (dias_consecutivos - 5) / 2 * 0.35, 3)
    else:
        return min(0.60 + (dias_consecutivos - 7) * 0.05, 1.0)


def calcular_indice_riesgo(
    usuario_id: str,
    sesiones: list[SesionEntrenamiento],
    metricas_fatiga: Optional[MetricasFatiga] = None,
    fecha_referencia: Optional[date] = None,
    duracion_minutos: float = 60.0
) -> IndiceRiesgo:
    if fecha_referencia is None:
        from datetime import date as _date
        fecha_referencia = _date.today()

    if metricas_fatiga is None:
        metricas_fatiga = calcular_metricas_fatiga(
            usuario_id, sesiones, fecha_referencia, duracion_minutos=duracion_minutos
        )

    mapa_cargas = construir_mapa_cargas(sesiones, duracion_minutos)

    fecha_7d = fecha_referencia - timedelta(days=6)
    sesiones_recientes = [
        s for s in sesiones
        if fecha_7d <= s.fecha <= fecha_referencia
    ]

    factores = {
        "acwr":          factor_riesgo_acwr(metricas_fatiga.acwr),
        "tsb":           factor_riesgo_tsb(metricas_fatiga.tsb),
        "spike_carga":   factor_riesgo_spike_carga(mapa_cargas, fecha_referencia),
        "sueno":         factor_riesgo_sueno(sesiones_recientes),
        "frecuencia_c":  factor_riesgo_frecuencia_cardiaca(sesiones_recientes),
        "dias_sin_desc": factor_riesgo_dias_consecutivos(mapa_cargas, fecha_referencia),
    }

    score = round(
        sum(PESOS_RIESGO[k] * v for k, v in factores.items()), 3
    )
    score = max(0.0, min(1.0, score))

    if score < 0.30:
        zona = ZonaRiesgo.VERDE
    elif score < 0.60:
        zona = ZonaRiesgo.AMARILLA
    else:
        zona = ZonaRiesgo.ROJA

    alertas = _generar_alertas(factores, metricas_fatiga, sesiones_recientes)

    return IndiceRiesgo(
        usuario_id=usuario_id,
        fecha=fecha_referencia,
        score=score,
        zona=zona,
        factores=factores,
        alertas=alertas,
    )


def _generar_alertas(
    factores: dict[str, float],
    metricas: MetricasFatiga,
    sesiones_recientes: list[SesionEntrenamiento]
) -> list[str]:
    alertas = []

    if metricas.acwr > 1.5:
        alertas.append(
            f"⚠️ ACWR elevado ({metricas.acwr:.2f}): carga aguda excede "
            f"1.5× la carga crónica. Reduce volumen esta semana."
        )
    elif metricas.acwr < 0.8:
        alertas.append(
            f"📉 ACWR bajo ({metricas.acwr:.2f}): posible desentrenamiento. "
            f"Incrementa carga gradualmente."
        )

    if metricas.tsb < -30:
        alertas.append(
            f"🔴 TSB crítico ({metricas.tsb:.1f}): señales de sobreentrenamiento. "
            f"Considera una semana de descarga."
        )
    elif metricas.tsb < -10:
        alertas.append(
            f"🟡 Fatiga acumulada (TSB {metricas.tsb:.1f}). "
            f"Monitorea signos de fatiga sistémica."
        )

    if factores["spike_carga"] > 0.50:
        alertas.append(
            "Spike de carga detectado: el volumen semanal aumentó >30%. "
            "Riesgo elevado de lesión por sobreuso."
        )

    horas_sueno = [
        s.horas_sueno for s in sesiones_recientes
        if s.horas_sueno is not None
    ]
    if horas_sueno and sum(horas_sueno) / len(horas_sueno) < 6:
        alertas.append(
            "Sueño insuficiente (<6h promedio): la recuperación está comprometida. "
            "Prioriza el descanso nocturno."
        )

    if factores["dias_sin_desc"] > 0.25:
        alertas.append(
            "Entrenamiento consecutivo sin días de descanso detectado. "
            "Incluye al menos 1-2 días de recuperación por semana."
        )

    return alertas