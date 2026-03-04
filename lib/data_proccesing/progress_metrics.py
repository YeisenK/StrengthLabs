from datetime import date, timedelta
from collections import defaultdict
from typing import Optional
from .models import SesionEntrenamiento, MetricasProgreso, Ejercicio
from .load_calculator import (
    calcular_volumen_sesion,
    calcular_intensidad_promedio_rpe,
    calcular_carga_ajustada_sesion,
)


def calcular_volumen_periodo(
    sesiones: list[SesionEntrenamiento],
    fecha_inicio: date,
    fecha_fin: date
) -> float:
    sesiones_rango = [
        s for s in sesiones if fecha_inicio <= s.fecha <= fecha_fin
    ]
    return round(sum(calcular_volumen_sesion(s) for s in sesiones_rango), 2)


def calcular_frecuencia_semanal(
    sesiones: list[SesionEntrenamiento],
    fecha_inicio: date,
    fecha_fin: date
) -> float:
    sesiones_rango = [
        s for s in sesiones if fecha_inicio <= s.fecha <= fecha_fin
    ]
    num_semanas = max(1, (fecha_fin - fecha_inicio).days / 7)
    return round(len(sesiones_rango) / num_semanas, 2)


def calcular_intensidad_promedio_periodo(
    sesiones: list[SesionEntrenamiento],
    fecha_inicio: date,
    fecha_fin: date
) -> float:
    sesiones_rango = [
        s for s in sesiones if fecha_inicio <= s.fecha <= fecha_fin
    ]
    if not sesiones_rango:
        return 0.0

    rpes = [calcular_intensidad_promedio_rpe(s) for s in sesiones_rango]
    return round(sum(rpes) / len(rpes), 2)


def calcular_tendencia_peso_corporal(
    sesiones: list[SesionEntrenamiento],
    dias: int = 28
) -> float:
    fecha_limite = date.today() - timedelta(days=dias)
    datos_peso = [
        (s.fecha, s.peso_corporal_kg)
        for s in sesiones
        if s.peso_corporal_kg is not None and s.fecha >= fecha_limite
    ]

    if len(datos_peso) < 2:
        return 0.0

    datos_peso.sort(key=lambda x: x[0])
    n = len(datos_peso)

    dia_base = datos_peso[0][0]
    x = [(d - dia_base).days for d, _ in datos_peso]
    y = [peso for _, peso in datos_peso]

    x_mean = sum(x) / n
    y_mean = sum(y) / n

    numerador = sum((xi - x_mean) * (yi - y_mean) for xi, yi in zip(x, y))
    denominador = sum((xi - x_mean) ** 2 for xi in x)

    if denominador == 0:
        return 0.0

    pendiente_diaria = numerador / denominador
    pendiente_semanal = round(pendiente_diaria * 7, 3)
    return pendiente_semanal


def calcular_promedio_sueno(
    sesiones: list[SesionEntrenamiento],
    dias: int = 7
) -> float:
    fecha_limite = date.today() - timedelta(days=dias)
    horas = [
        s.horas_sueno
        for s in sesiones
        if s.horas_sueno is not None and s.fecha >= fecha_limite
    ]
    if not horas:
        return 0.0
    return round(sum(horas) / len(horas), 2)


def calcular_progreso_ejercicio(
    sesiones: list[SesionEntrenamiento],
    nombre_ejercicio: str,
    dias: int = 90
) -> dict:
    fecha_limite = date.today() - timedelta(days=dias)

    registros: list[tuple[date, Ejercicio]] = []
    for sesion in sesiones:
        if sesion.fecha < fecha_limite:
            continue
        for ej in sesion.ejercicios:
            if ej.nombre.lower() == nombre_ejercicio.lower():
                registros.append((sesion.fecha, ej))

    if not registros:
        return {
            "ejercicio": nombre_ejercicio,
            "registros": 0,
            "e1rm_inicial": None,
            "e1rm_actual": None,
            "cambio_e1rm": None,
            "tendencia_semanal_kg": 0.0,
        }

    registros.sort(key=lambda x: x[0])

    def calcular_e1rm(ej: Ejercicio) -> float:
        return round(ej.peso_kg * (1 + ej.repeticiones / 30), 2)

    e1rms = [(fecha, calcular_e1rm(ej)) for fecha, ej in registros]
    e1rm_inicial = e1rms[0][1]
    e1rm_actual = e1rms[-1][1]
    cambio_e1rm = round(e1rm_actual - e1rm_inicial, 2)

    if len(e1rms) >= 2:
        n = len(e1rms)
        dia_base = e1rms[0][0]
        x = [(d - dia_base).days for d, _ in e1rms]
        y = [v for _, v in e1rms]
        x_mean = sum(x) / n
        y_mean = sum(y) / n
        num = sum((xi - x_mean) * (yi - y_mean) for xi, yi in zip(x, y))
        den = sum((xi - x_mean) ** 2 for xi in x)
        tendencia_semanal = round((num / den * 7) if den != 0 else 0.0, 3)
    else:
        tendencia_semanal = 0.0

    return {
        "ejercicio": nombre_ejercicio,
        "registros": len(registros),
        "e1rm_inicial": e1rm_inicial,
        "e1rm_actual": e1rm_actual,
        "cambio_e1rm": cambio_e1rm,
        "tendencia_semanal_kg": tendencia_semanal,
    }


def obtener_ejercicios_registrados(
    sesiones: list[SesionEntrenamiento]
) -> list[str]:
    nombres = set()
    for sesion in sesiones:
        for ej in sesion.ejercicios:
            nombres.add(ej.nombre.lower())
    return sorted(nombres)


def calcular_progreso_todos_ejercicios(
    sesiones: list[SesionEntrenamiento],
    dias: int = 90
) -> list[dict]:
    nombres = obtener_ejercicios_registrados(sesiones)
    return [calcular_progreso_ejercicio(sesiones, nombre, dias) for nombre in nombres]


def calcular_metricas_progreso(
    usuario_id: str,
    sesiones: list[SesionEntrenamiento],
    fecha_referencia: Optional[date] = None,
    ventana_dias: int = 28
) -> MetricasProgreso:
    if fecha_referencia is None:
        fecha_referencia = date.today()

    fecha_inicio = fecha_referencia - timedelta(days=ventana_dias - 1)

    volumen_total = calcular_volumen_periodo(sesiones, fecha_inicio, fecha_referencia)
    intensidad_rpe = calcular_intensidad_promedio_periodo(sesiones, fecha_inicio, fecha_referencia)
    tendencia_peso = calcular_tendencia_peso_corporal(sesiones, dias=ventana_dias)
    tendencia_sueno = calcular_promedio_sueno(sesiones, dias=7)
    frecuencia = calcular_frecuencia_semanal(sesiones, fecha_inicio, fecha_referencia)

    return MetricasProgreso(
        usuario_id=usuario_id,
        fecha=fecha_referencia,
        volumen_total_kg=volumen_total,
        intensidad_promedio_rpe=intensidad_rpe,
        tendencia_peso_corporal=tendencia_peso,
        tendencia_sueno=tendencia_sueno,
        frecuencia_semanal=frecuencia,
    )


def historial_volumen_semanal(
    sesiones: list[SesionEntrenamiento],
    num_semanas: int = 12
) -> list[dict]:
    hoy = date.today()
    resultado = []

    for i in range(num_semanas - 1, -1, -1):
        semana_fin = hoy - timedelta(weeks=i)
        semana_inicio = semana_fin - timedelta(days=6)

        sesiones_semana = [
            s for s in sesiones
            if semana_inicio <= s.fecha <= semana_fin
        ]
        volumen = round(sum(calcular_volumen_sesion(s) for s in sesiones_semana), 2)

        resultado.append({
            "semana_inicio": semana_inicio,
            "semana_fin": semana_fin,
            "volumen_kg": volumen,
            "num_sesiones": len(sesiones_semana),
        })

    return resultado