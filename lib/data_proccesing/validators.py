from datetime import date
from typing import Optional
from .models import Ejercicio, SesionEntrenamiento


class ResultadoValidacion:

    def __init__(self, valido: bool, errores: list[str] = None):
        self.valido = valido
        self.errores = errores or []

    def __bool__(self):
        return self.valido

    def __repr__(self):
        return f"ResultadoValidacion(valido={self.valido}, errores={self.errores})"

    def agregar_error(self, mensaje: str):
        self.errores.append(mensaje)
        self.valido = False


def validar_ejercicio(datos: dict) -> ResultadoValidacion:
    resultado = ResultadoValidacion(valido=True)

    nombre = datos.get("nombre", "")
    if not isinstance(nombre, str) or not nombre.strip():
        resultado.agregar_error("El nombre del ejercicio es requerido.")
    elif len(nombre.strip()) > 100:
        resultado.agregar_error("El nombre del ejercicio no puede superar 100 caracteres.")

    series = datos.get("series")
    if series is None:
        resultado.agregar_error("El número de series es requerido.")
    elif not isinstance(series, int) or not (1 <= series <= 20):
        resultado.agregar_error("Las series deben ser un entero entre 1 y 20.")

    reps = datos.get("repeticiones")
    if reps is None:
        resultado.agregar_error("El número de repeticiones es requerido.")
    elif not isinstance(reps, int) or not (1 <= reps <= 100):
        resultado.agregar_error("Las repeticiones deben ser un entero entre 1 y 100.")

    peso = datos.get("peso_kg")
    if peso is None:
        resultado.agregar_error("El peso es requerido.")
    elif not isinstance(peso, (int, float)) or not (0 <= peso <= 1000):
        resultado.agregar_error("El peso debe ser un número entre 0 y 1000 kg.")

    rir = datos.get("rir")
    rpe = datos.get("rpe")

    if rir is None and rpe is None:
        resultado.agregar_error("Se requiere al menos RIR o RPE.")

    if rir is not None:
        if not isinstance(rir, int) or not (0 <= rir <= 5):
            resultado.agregar_error("RIR debe ser un entero entre 0 y 5.")

    if rpe is not None:
        if not isinstance(rpe, (int, float)) or not (1 <= rpe <= 10):
            resultado.agregar_error("RPE debe ser un número entre 1 y 10.")

    return resultado


def validar_sesion(datos: dict) -> ResultadoValidacion:
    resultado = ResultadoValidacion(valido=True)

    if not datos.get("usuario_id"):
        resultado.agregar_error("El ID de usuario es requerido.")

    fecha = datos.get("fecha")
    if fecha is None:
        resultado.agregar_error("La fecha de la sesión es requerida.")
    else:
        if isinstance(fecha, str):
            try:
                from datetime import datetime
                fecha = datetime.strptime(fecha, "%Y-%m-%d").date()
            except ValueError:
                resultado.agregar_error(
                    "Formato de fecha inválido. Use YYYY-MM-DD."
                )
        if isinstance(fecha, date) and fecha > date.today():
            resultado.agregar_error("La fecha no puede ser futura.")

    ejercicios = datos.get("ejercicios", [])
    if not ejercicios:
        resultado.agregar_error("La sesión debe incluir al menos un ejercicio.")
    elif not isinstance(ejercicios, list):
        resultado.agregar_error("El campo ejercicios debe ser una lista.")
    else:
        for i, ej_datos in enumerate(ejercicios):
            res_ej = validar_ejercicio(ej_datos)
            if not res_ej.valido:
                for error in res_ej.errores:
                    resultado.agregar_error(f"Ejercicio {i + 1}: {error}")

    fc = datos.get("frecuencia_cardiaca_promedio")
    if fc is not None:
        if not isinstance(fc, (int, float)) or not (30 <= fc <= 250):
            resultado.agregar_error(
                "Frecuencia cardíaca debe estar entre 30 y 250 bpm."
            )

    peso = datos.get("peso_corporal_kg")
    if peso is not None:
        if not isinstance(peso, (int, float)) or not (20 <= peso <= 300):
            resultado.agregar_error(
                "Peso corporal debe estar entre 20 y 300 kg."
            )

    sueno = datos.get("horas_sueno")
    if sueno is not None:
        if not isinstance(sueno, (int, float)) or not (0 <= sueno <= 24):
            resultado.agregar_error(
                "Horas de sueño deben estar entre 0 y 24."
            )

    return resultado


def validar_rango_fechas(
    fecha_inicio: date,
    fecha_fin: date,
    max_dias: int = 365
) -> ResultadoValidacion:
    resultado = ResultadoValidacion(valido=True)

    if fecha_inicio > fecha_fin:
        resultado.agregar_error("La fecha de inicio debe ser anterior a la fecha de fin.")

    delta = (fecha_fin - fecha_inicio).days
    if delta > max_dias:
        resultado.agregar_error(
            f"El rango no puede superar {max_dias} días. Rango solicitado: {delta} días."
        )

    if fecha_fin > date.today():
        resultado.agregar_error("La fecha de fin no puede ser futura.")

    return resultado


def sanitizar_string(valor: str, max_len: int = 200) -> str:
    if not isinstance(valor, str):
        return ""
    sanitizado = "".join(c for c in valor if c.isprintable())
    return sanitizado.strip()[:max_len]


def sanitizar_sesion_dict(datos: dict) -> dict:
    sanitizado = datos.copy()

    if "usuario_id" in sanitizado:
        sanitizado["usuario_id"] = sanitizar_string(
            str(sanitizado["usuario_id"]), max_len=64
        )

    if "notas" in sanitizado and sanitizado["notas"]:
        sanitizado["notas"] = sanitizar_string(sanitizado["notas"], max_len=500)

    for campo_float in ["frecuencia_cardiaca_promedio", "peso_corporal_kg", "horas_sueno"]:
        if campo_float in sanitizado and sanitizado[campo_float] is not None:
            try:
                sanitizado[campo_float] = float(sanitizado[campo_float])
            except (ValueError, TypeError):
                sanitizado[campo_float] = None

    if "ejercicios" in sanitizado and isinstance(sanitizado["ejercicios"], list):
        for ej in sanitizado["ejercicios"]:
            if isinstance(ej, dict):
                if "nombre" in ej:
                    ej["nombre"] = sanitizar_string(str(ej["nombre"]), max_len=100)
                for campo in ["series", "repeticiones"]:
                    if campo in ej:
                        try:
                            ej[campo] = int(ej[campo])
                        except (ValueError, TypeError):
                            ej[campo] = None
                for campo in ["peso_kg", "rpe"]:
                    if campo in ej and ej[campo] is not None:
                        try:
                            ej[campo] = float(ej[campo])
                        except (ValueError, TypeError):
                            ej[campo] = None
                if "rir" in ej and ej["rir"] is not None:
                    try:
                        ej["rir"] = int(ej["rir"])
                    except (ValueError, TypeError):
                        ej["rir"] = None

    return sanitizado