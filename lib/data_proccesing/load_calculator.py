from datetime import date
from typing import Optional
from .models import Ejercicio, SesionEntrenamiento


def rpe_desde_rir(rir: int) -> float:
    if not (0 <= rir <= 5):
        raise ValueError(f"RIR debe estar entre 0 y 5, recibido: {rir}")
    return float(10 - rir)


def calcular_carga_ejercicio(ejercicio: Ejercicio) -> float:
    rpe = ejercicio.rpe
    if rpe is None:
        rpe = rpe_desde_rir(ejercicio.rir)

    carga_mecanica = ejercicio.series * ejercicio.repeticiones * ejercicio.peso_kg
    modificador_rpe = rpe / 10.0
    return round(carga_mecanica * modificador_rpe, 2)


def calcular_volumen_ejercicio(ejercicio: Ejercicio) -> float:
    return round(ejercicio.series * ejercicio.repeticiones * ejercicio.peso_kg, 2)


def calcular_srpe_sesion(
    sesion: SesionEntrenamiento,
    duracion_minutos: float = 60.0
) -> float:
    if not sesion.ejercicios:
        return 0.0

    total_series = 0
    suma_ponderada_rpe = 0.0

    for ej in sesion.ejercicios:
        rpe = ej.rpe if ej.rpe is not None else rpe_desde_rir(ej.rir)
        suma_ponderada_rpe += rpe * ej.series
        total_series += ej.series

    rpe_global = suma_ponderada_rpe / total_series if total_series > 0 else 5.0
    return round(duracion_minutos * rpe_global, 2)


def calcular_carga_sesion(sesion: SesionEntrenamiento) -> float:
    return round(sum(calcular_carga_ejercicio(ej) for ej in sesion.ejercicios), 2)


def calcular_volumen_sesion(sesion: SesionEntrenamiento) -> float:
    return round(sum(calcular_volumen_ejercicio(ej) for ej in sesion.ejercicios), 2)


def calcular_intensidad_promedio_rpe(sesion: SesionEntrenamiento) -> float:
    if not sesion.ejercicios:
        return 0.0

    rpes = []
    for ej in sesion.ejercicios:
        rpe = ej.rpe if ej.rpe is not None else rpe_desde_rir(ej.rir)
        rpes.append(rpe)

    return round(sum(rpes) / len(rpes), 2)


def ajustar_carga_por_sueno(carga: float, horas_sueno: Optional[float]) -> float:
    if horas_sueno is None:
        return carga

    if horas_sueno < 5:
        modificador = 1.25
    elif horas_sueno < 6:
        modificador = 1.10
    elif horas_sueno <= 8:
        modificador = 1.00
    else:
        modificador = 0.95

    return round(carga * modificador, 2)


def calcular_carga_ajustada_sesion(
    sesion: SesionEntrenamiento,
    duracion_minutos: float = 60.0
) -> float:
    srpe = calcular_srpe_sesion(sesion, duracion_minutos)
    carga_mecanica_norm = calcular_carga_sesion(sesion) / 1000.0

    carga_combinada = (srpe * 0.70) + (carga_mecanica_norm * 0.30)
    carga_final = ajustar_carga_por_sueno(carga_combinada, sesion.horas_sueno)

    return round(carga_final, 2)


def resumen_sesion(
    sesion: SesionEntrenamiento,
    duracion_minutos: float = 60.0
) -> dict:
    return {
        "fecha": sesion.fecha,
        "volumen_kg": calcular_volumen_sesion(sesion),
        "carga_ua": calcular_carga_sesion(sesion),
        "srpe": calcular_srpe_sesion(sesion, duracion_minutos),
        "intensidad_rpe": calcular_intensidad_promedio_rpe(sesion),
        "carga_ajustada": calcular_carga_ajustada_sesion(sesion, duracion_minutos),
        "num_ejercicios": len(sesion.ejercicios),
        "total_series": sum(ej.series for ej in sesion.ejercicios),
    }