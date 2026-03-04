from datetime import date, timedelta
from typing import Optional
from .models import (
    MetricasFatiga, SesionEntrenamiento, ZonaRiesgo, NivelFatiga
)
from .load_calculator import calcular_carga_ajustada_sesion


VENTANA_AGUDA_DIAS = 7
VENTANA_CRONICA_DIAS = 28

ACWR_ZONA_VERDE_MIN = 0.8
ACWR_ZONA_VERDE_MAX = 1.3
ACWR_ZONA_AMARILLA_MAX = 1.5

TSB_FRESCO = 10.0
TSB_FATIGADO = -10.0
TSB_SOBREENTRENADO = -30.0


def construir_mapa_cargas(
    sesiones: list[SesionEntrenamiento],
    duracion_minutos: float = 60.0
) -> dict[date, float]:
    mapa: dict[date, float] = {}
    for sesion in sesiones:
        carga = calcular_carga_ajustada_sesion(sesion, duracion_minutos)
        mapa[sesion.fecha] = mapa.get(sesion.fecha, 0.0) + carga
    return mapa


def obtener_cargas_rango(
    mapa_cargas: dict[date, float],
    fecha_inicio: date,
    fecha_fin: date
) -> list[float]:
    cargas = []
    delta = (fecha_fin - fecha_inicio).days + 1
    for i in range(delta):
        dia = fecha_inicio + timedelta(days=i)
        cargas.append(mapa_cargas.get(dia, 0.0))
    return cargas


def calcular_atl(
    mapa_cargas: dict[date, float],
    fecha_referencia: date
) -> float:
    fecha_inicio = fecha_referencia - timedelta(days=VENTANA_AGUDA_DIAS - 1)
    cargas = obtener_cargas_rango(mapa_cargas, fecha_inicio, fecha_referencia)
    return round(sum(cargas) / VENTANA_AGUDA_DIAS, 2)


def calcular_atl_ewma(
    mapa_cargas: dict[date, float],
    fecha_referencia: date,
    tau: float = 7.0
) -> float:
    lambda_factor = 2.0 / (tau + 1.0)
    fecha_inicio = fecha_referencia - timedelta(days=VENTANA_CRONICA_DIAS)

    fechas = sorted(mapa_cargas.keys())
    fechas_rango = [f for f in fechas if fecha_inicio <= f <= fecha_referencia]

    if not fechas_rango:
        return 0.0

    ewma = mapa_cargas.get(fechas_rango[0], 0.0)
    for fecha in fechas_rango[1:]:
        carga = mapa_cargas.get(fecha, 0.0)
        ewma = lambda_factor * carga + (1 - lambda_factor) * ewma

    return round(ewma, 2)


def calcular_ctl(
    mapa_cargas: dict[date, float],
    fecha_referencia: date
) -> float:
    fecha_inicio = fecha_referencia - timedelta(days=VENTANA_CRONICA_DIAS - 1)
    cargas = obtener_cargas_rango(mapa_cargas, fecha_inicio, fecha_referencia)
    return round(sum(cargas) / VENTANA_CRONICA_DIAS, 2)


def calcular_ctl_ewma(
    mapa_cargas: dict[date, float],
    fecha_referencia: date,
    tau: float = 28.0
) -> float:
    return calcular_atl_ewma(mapa_cargas, fecha_referencia, tau=tau)


def calcular_acwr(atl: float, ctl: float) -> float:
    if ctl == 0.0:
        return 0.0
    return round(atl / ctl, 3)


def clasificar_zona_riesgo_acwr(acwr: float) -> ZonaRiesgo:
    if ACWR_ZONA_VERDE_MIN <= acwr <= ACWR_ZONA_VERDE_MAX:
        return ZonaRiesgo.VERDE
    elif ACWR_ZONA_VERDE_MAX < acwr <= ACWR_ZONA_AMARILLA_MAX:
        return ZonaRiesgo.AMARILLA
    else:
        return ZonaRiesgo.ROJA


def calcular_tsb(ctl: float, atl: float) -> float:
    return round(ctl - atl, 2)


def clasificar_nivel_fatiga(tsb: float) -> NivelFatiga:
    if tsb > TSB_FRESCO:
        return NivelFatiga.FRESCO
    elif tsb > TSB_FATIGADO:
        return NivelFatiga.OPTIMO
    elif tsb > TSB_SOBREENTRENADO:
        return NivelFatiga.FATIGADO
    else:
        return NivelFatiga.SOBREENTRENADO


def calcular_metricas_fatiga(
    usuario_id: str,
    sesiones: list[SesionEntrenamiento],
    fecha_referencia: Optional[date] = None,
    usar_ewma: bool = True,
    duracion_minutos: float = 60.0
) -> MetricasFatiga:
    if fecha_referencia is None:
        from datetime import date as _date
        fecha_referencia = _date.today()

    mapa = construir_mapa_cargas(sesiones, duracion_minutos)

    if usar_ewma:
        atl = calcular_atl_ewma(mapa, fecha_referencia)
        ctl = calcular_ctl_ewma(mapa, fecha_referencia)
    else:
        atl = calcular_atl(mapa, fecha_referencia)
        ctl = calcular_ctl(mapa, fecha_referencia)

    acwr = calcular_acwr(atl, ctl)
    tsb = calcular_tsb(ctl, atl)
    zona = clasificar_zona_riesgo_acwr(acwr)
    nivel = clasificar_nivel_fatiga(tsb)

    return MetricasFatiga(
        usuario_id=usuario_id,
        fecha=fecha_referencia,
        atl=atl,
        ctl=ctl,
        acwr=acwr,
        tsb=tsb,
        zona_riesgo=zona,
        nivel_fatiga=nivel,
    )


def historial_metricas_fatiga(
    usuario_id: str,
    sesiones: list[SesionEntrenamiento],
    fecha_inicio: date,
    fecha_fin: date,
    usar_ewma: bool = True,
    duracion_minutos: float = 60.0
) -> list[MetricasFatiga]:
    resultados = []
    delta = (fecha_fin - fecha_inicio).days + 1

    for i in range(delta):
        fecha = fecha_inicio + timedelta(days=i)
        metricas = calcular_metricas_fatiga(
            usuario_id, sesiones, fecha, usar_ewma, duracion_minutos
        )
        resultados.append(metricas)

    return resultados