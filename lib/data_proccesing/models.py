from dataclasses import dataclass, field
from datetime import date, datetime
from enum import Enum
from typing import Optional


class ZonaRiesgo(str, Enum):
    VERDE = "verde"
    AMARILLA = "amarilla"
    ROJA = "roja"


class NivelFatiga(str, Enum):
    FRESCO = "fresco"
    OPTIMO = "optimo"
    FATIGADO = "fatigado"
    SOBREENTRENADO = "sobreentrenado"


class FasePeriodizacion(str, Enum):
    ACUMULACION = "acumulacion"
    INTENSIFICACION = "intensificacion"
    REALIZACION = "realizacion"
    DESCARGA = "descarga"


@dataclass
class Ejercicio:
    nombre: str
    series: int
    repeticiones: int
    peso_kg: float
    rir: Optional[int] = None
    rpe: Optional[float] = None

    def __post_init__(self):
        if self.rir is None and self.rpe is None:
            raise ValueError("Se requiere al menos RIR o RPE por ejercicio.")
        if self.rir is not None and not (0 <= self.rir <= 5):
            raise ValueError("RIR debe estar entre 0 y 5.")
        if self.rpe is not None and not (1 <= self.rpe <= 10):
            raise ValueError("RPE debe estar entre 1 y 10.")
        if self.series <= 0 or self.repeticiones <= 0:
            raise ValueError("Series y repeticiones deben ser positivos.")
        if self.peso_kg < 0:
            raise ValueError("El peso no puede ser negativo.")


@dataclass
class SesionEntrenamiento:
    usuario_id: str
    fecha: date
    ejercicios: list[Ejercicio]
    frecuencia_cardiaca_promedio: Optional[float] = None
    peso_corporal_kg: Optional[float] = None
    horas_sueno: Optional[float] = None
    notas: Optional[str] = None
    sesion_id: Optional[str] = None

    def __post_init__(self):
        if not self.ejercicios:
            raise ValueError("Una sesión debe tener al menos un ejercicio.")
        if self.frecuencia_cardiaca_promedio is not None:
            if not (30 <= self.frecuencia_cardiaca_promedio <= 250):
                raise ValueError("Frecuencia cardíaca fuera de rango fisiológico.")
        if self.horas_sueno is not None:
            if not (0 <= self.horas_sueno <= 24):
                raise ValueError("Horas de sueño inválidas.")


@dataclass
class MetricasFatiga:
    usuario_id: str
    fecha: date
    atl: float
    ctl: float
    acwr: float
    tsb: float
    zona_riesgo: ZonaRiesgo
    nivel_fatiga: NivelFatiga


@dataclass
class IndiceRiesgo:
    usuario_id: str
    fecha: date
    score: float
    zona: ZonaRiesgo
    factores: dict[str, float] = field(default_factory=dict)
    alertas: list[str] = field(default_factory=list)


@dataclass
class PlanSemanal:
    usuario_id: str
    semana_inicio: date
    fase: FasePeriodizacion
    sesiones_recomendadas: int
    volumen_relativo: float
    intensidad_relativa: float
    ejercicios_sugeridos: list[str] = field(default_factory=list)
    notas_entrenador: Optional[str] = None


@dataclass
class MetricasProgreso:
    usuario_id: str
    fecha: date
    volumen_total_kg: float
    intensidad_promedio_rpe: float
    tendencia_peso_corporal: float
    tendencia_sueno: float
    frecuencia_semanal: float