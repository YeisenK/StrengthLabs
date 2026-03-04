from .models import (
    Ejercicio,
    SesionEntrenamiento,
    MetricasFatiga,
    IndiceRiesgo,
    PlanSemanal,
    MetricasProgreso,
    ZonaRiesgo,
    NivelFatiga,
    FasePeriodizacion,
)

from .load_calculator import (
    rpe_desde_rir,
    calcular_carga_ejercicio,
    calcular_volumen_ejercicio,
    calcular_srpe_sesion,
    calcular_carga_sesion,
    calcular_volumen_sesion,
    calcular_intensidad_promedio_rpe,
    ajustar_carga_por_sueno,
    calcular_carga_ajustada_sesion,
    resumen_sesion,
)

from .fatigue_engine import (
    construir_mapa_cargas,
    calcular_atl,
    calcular_atl_ewma,
    calcular_ctl,
    calcular_ctl_ewma,
    calcular_acwr,
    clasificar_zona_riesgo_acwr,
    calcular_tsb,
    clasificar_nivel_fatiga,
    calcular_metricas_fatiga,
    historial_metricas_fatiga,
)

from .risk_engine import (
    factor_riesgo_acwr,
    factor_riesgo_tsb,
    factor_riesgo_spike_carga,
    factor_riesgo_sueno,
    factor_riesgo_frecuencia_cardiaca,
    factor_riesgo_dias_consecutivos,
    calcular_indice_riesgo,
)

from .periodization_engine import (
    detectar_fase_automatica,
    ajustar_volumen,
    ajustar_intensidad,
    ajustar_sesiones_semana,
    generar_plan_semanal,
    proyectar_planes_macrociclo,
)

from .progress_metrics import (
    calcular_volumen_periodo,
    calcular_frecuencia_semanal,
    calcular_intensidad_promedio_periodo,
    calcular_tendencia_peso_corporal,
    calcular_promedio_sueno,
    calcular_progreso_ejercicio,
    calcular_progreso_todos_ejercicios,
    obtener_ejercicios_registrados,
    calcular_metricas_progreso,
    historial_volumen_semanal,
)

from .validators import (
    ResultadoValidacion,
    validar_ejercicio,
    validar_sesion,
    validar_rango_fechas,
    sanitizar_string,
    sanitizar_sesion_dict,
)

from .dashboard import (
    generar_datos_dashboard,
    obtener_sesiones_recientes,
    construir_datos_grafica_fatiga,
    construir_datos_grafica_volumen,
)

__version__ = "1.0.0"
__author__ = "StrengthLabs — Oscar Cruz, Cristina Enríquez, Yeisen López"
