from datetime import date
from typing import Optional
from .models import SesionEntrenamiento
from .fatigue_engine import calcular_metricas_fatiga, historial_metricas_fatiga
from .risk_engine import calcular_indice_riesgo
from .periodization_engine import generar_plan_semanal
from .progress_metrics import (
    calcular_metricas_progreso,
    calcular_progreso_todos_ejercicios,
    historial_volumen_semanal,
    calcular_promedio_sueno,
)
from .load_calculator import resumen_sesion


# ──────────────────────────────────────────────
#  Funciones de agregación
# ──────────────────────────────────────────────

def obtener_sesiones_recientes(
    sesiones: list[SesionEntrenamiento],
    limite: int = 5
) -> list[dict]:

    sesiones_ordenadas = sorted(sesiones, key=lambda s: s.fecha, reverse=True)
    resultado = []

    for sesion in sesiones_ordenadas[:limite]:
        resumen = resumen_sesion(sesion)
        resumen["sesion_id"] = sesion.sesion_id
        resumen["usuario_id"] = sesion.usuario_id
        resumen["ejercicios"] = [
            {
                "nombre": ej.nombre,
                "series": ej.series,
                "repeticiones": ej.repeticiones,
                "peso_kg": ej.peso_kg,
                "rpe": ej.rpe,
                "rir": ej.rir,
            }
            for ej in sesion.ejercicios
        ]
        resultado.append(resumen)

    return resultado


def construir_datos_grafica_fatiga(
    usuario_id: str,
    sesiones: list[SesionEntrenamiento],
    dias: int = 28
) -> list[dict]:

    fecha_fin = date.today()
    fecha_inicio = fecha_fin.__class__.fromordinal(fecha_fin.toordinal() - dias + 1)

    historial = historial_metricas_fatiga(
        usuario_id, sesiones, fecha_inicio, fecha_fin
    )

    return [
        {
            "fecha": str(m.fecha),
            "atl": m.atl,
            "ctl": m.ctl,
            "acwr": m.acwr,
            "tsb": m.tsb,
            "zona_riesgo": m.zona_riesgo.value,
        }
        for m in historial
    ]


def construir_datos_grafica_volumen(
    sesiones: list[SesionEntrenamiento],
    num_semanas: int = 12
) -> list[dict]:

    historial = historial_volumen_semanal(sesiones, num_semanas)
    return [
        {
            "semana_inicio": str(s["semana_inicio"]),
            "semana_fin": str(s["semana_fin"]),
            "volumen_kg": s["volumen_kg"],
            "num_sesiones": s["num_sesiones"],
        }
        for s in historial
    ]


# ──────────────────────────────────────────────
#  Dashboard
# ──────────────────────────────────────────────

def generar_datos_dashboard(
    usuario_id: str,
    sesiones: list[SesionEntrenamiento],
    fecha_referencia: Optional[date] = None,
    semanas_macrociclo: int = 0,
    duracion_minutos: float = 60.0,
) -> dict:

    if fecha_referencia is None:
        fecha_referencia = date.today()

    metricas_fatiga = calcular_metricas_fatiga(
        usuario_id, sesiones, fecha_referencia,
        duracion_minutos=duracion_minutos
    )

    indice_riesgo = calcular_indice_riesgo(
        usuario_id, sesiones, metricas_fatiga,
        fecha_referencia, duracion_minutos
    )

    plan = generar_plan_semanal(
        usuario_id, metricas_fatiga, indice_riesgo,
        semanas_desde_inicio=semanas_macrociclo
    )

    progreso = calcular_metricas_progreso(
        usuario_id, sesiones, fecha_referencia
    )

    grafica_fatiga = construir_datos_grafica_fatiga(usuario_id, sesiones, dias=28)
    grafica_volumen = construir_datos_grafica_volumen(sesiones, num_semanas=12)

    progreso_ejercicios = calcular_progreso_todos_ejercicios(sesiones)

    sesiones_recientes = obtener_sesiones_recientes(sesiones, limite=5)

    sueno_7d = calcular_promedio_sueno(sesiones, dias=7)

    return {
        "usuario_id": usuario_id,
        "fecha": str(fecha_referencia),

        "metricas_fatiga": {
            "atl": metricas_fatiga.atl,
            "ctl": metricas_fatiga.ctl,
            "acwr": metricas_fatiga.acwr,
            "tsb": metricas_fatiga.tsb,
            "zona_riesgo": metricas_fatiga.zona_riesgo.value,
            "nivel_fatiga": metricas_fatiga.nivel_fatiga.value,
        },

        "indice_riesgo": {
            "score": indice_riesgo.score,
            "zona": indice_riesgo.zona.value,
            "factores": indice_riesgo.factores,
        },

        "plan_semanal": {
            "semana_inicio": str(plan.semana_inicio),
            "fase": plan.fase.value,
            "sesiones_recomendadas": plan.sesiones_recomendadas,
            "volumen_relativo": plan.volumen_relativo,
            "intensidad_relativa": plan.intensidad_relativa,
            "ejercicios_sugeridos": plan.ejercicios_sugeridos,
            "notas": plan.notas_entrenador,
        },

        "metricas_progreso": {
            "volumen_total_kg": progreso.volumen_total_kg,
            "intensidad_promedio_rpe": progreso.intensidad_promedio_rpe,
            "tendencia_peso_corporal_kg_semana": progreso.tendencia_peso_corporal,
            "frecuencia_semanal": progreso.frecuencia_semanal,
        },

        "sesiones_recientes": sesiones_recientes,
        "grafica_fatiga": grafica_fatiga,
        "grafica_volumen": grafica_volumen,
        "progreso_ejercicios": progreso_ejercicios,
        "alertas_activas": indice_riesgo.alertas,
        "sueno_promedio_7d": sueno_7d,
    }
