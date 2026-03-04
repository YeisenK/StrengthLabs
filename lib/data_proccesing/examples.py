from datetime import date, timedelta
from data_processing import ( # type: ignore
    Ejercicio, SesionEntrenamiento,
    resumen_sesion, calcular_carga_ajustada_sesion,
    calcular_metricas_fatiga, historial_metricas_fatiga,
    calcular_indice_riesgo,
    generar_plan_semanal, proyectar_planes_macrociclo,
    calcular_metricas_progreso, calcular_progreso_ejercicio,
    historial_volumen_semanal,
    validar_sesion, sanitizar_sesion_dict,
    generar_datos_dashboard,
)


# ──────────────────────────────────────────────
#  Datos de prueba
# ──────────────────────────────────────────────

def crear_sesiones_prueba() -> list[SesionEntrenamiento]:
    hoy = date.today()
    sesiones = []

    ejercicios_dia1 = [
        Ejercicio("Sentadilla con barra", series=5, repeticiones=5, peso_kg=100.0, rpe=8.0),
        Ejercicio("Press de banca", series=4, repeticiones=8, peso_kg=70.0, rir=2),
        Ejercicio("Remo con barra", series=4, repeticiones=8, peso_kg=80.0, rpe=7.5),
    ]

    ejercicios_dia2 = [
        Ejercicio("Peso muerto", series=3, repeticiones=5, peso_kg=140.0, rpe=8.5),
        Ejercicio("Press militar", series=4, repeticiones=6, peso_kg=55.0, rir=2),
        Ejercicio("Dominadas lastradas", series=4, repeticiones=6, peso_kg=20.0, rpe=8.0),
    ]

    for i in range(35):
        if i % 7 in [5, 6]:
            continue

        fecha = hoy - timedelta(days=34 - i)
        ejercicios = ejercicios_dia1 if i % 2 == 0 else ejercicios_dia2

        sesion = SesionEntrenamiento(
            usuario_id="user_001",
            fecha=fecha,
            ejercicios=ejercicios,
            frecuencia_cardiaca_promedio=145.0 + (i % 5) * 3,
            peso_corporal_kg=80.0 + (i * 0.02),
            horas_sueno=7.0 + (i % 3) * 0.5,
            sesion_id=f"ses_{i:03d}",
        )
        sesiones.append(sesion)

    return sesiones


# ──────────────────────────────────────────────
#  Ejemplos por módulo
# ──────────────────────────────────────────────

def ejemplo_carga():
    print("\n" + "=" * 60)
    print("EJEMPLO 1: Cálculo de Carga de Sesión")
    print("=" * 60)

    sesion = SesionEntrenamiento(
        usuario_id="user_001",
        fecha=date.today(),
        ejercicios=[
            Ejercicio("Sentadilla con barra", 5, 5, 100.0, rpe=8.0),
            Ejercicio("Press de banca", 4, 8, 70.0, rir=2),
        ],
        horas_sueno=7.5,
        peso_corporal_kg=80.0,
    )

    resumen = resumen_sesion(sesion, duracion_minutos=75)
    print(f"Fecha:             {resumen['fecha']}")
    print(f"Volumen total:     {resumen['volumen_kg']:,.1f} kg")
    print(f"Carga mecánica:    {resumen['carga_ua']:,.1f} UA")
    print(f"sRPE:              {resumen['srpe']:,.1f} UA")
    print(f"Intensidad RPE:    {resumen['intensidad_rpe']:.1f}")
    print(f"Carga ajustada:    {resumen['carga_ajustada']:,.1f} UA")
    print(f"Ejercicios:        {resumen['num_ejercicios']}")
    print(f"Total series:      {resumen['total_series']}")


def ejemplo_fatiga():
    print("\n" + "=" * 60)
    print("EJEMPLO 2: Motor de Fatiga — ACWR / TSB")
    print("=" * 60)

    sesiones = crear_sesiones_prueba()
    metricas = calcular_metricas_fatiga("user_001", sesiones)

    print(f"Fecha:             {metricas.fecha}")
    print(f"ATL (7 días):      {metricas.atl:.2f} UA")
    print(f"CTL (28 días):     {metricas.ctl:.2f} UA")
    print(f"ACWR:              {metricas.acwr:.3f}")
    print(f"TSB:               {metricas.tsb:.2f}")
    print(f"Zona de riesgo:    {metricas.zona_riesgo.value.upper()}")
    print(f"Nivel de fatiga:   {metricas.nivel_fatiga.value.upper()}")


def ejemplo_riesgo():
    print("\n" + "=" * 60)
    print("EJEMPLO 3: Índice de Riesgo de Lesión")
    print("=" * 60)

    sesiones = crear_sesiones_prueba()
    indice = calcular_indice_riesgo("user_001", sesiones)

    print(f"Score de riesgo:   {indice.score:.3f} / 1.000")
    print(f"Zona:              {indice.zona.value.upper()}")
    print("\nFactores desglosados:")
    for factor, valor in indice.factores.items():
        barra = "█" * int(valor * 20)
        print(f"  {factor:<20} {valor:.3f}  {barra}")

    if indice.alertas:
        print("\n  Alertas activas:")
        for alerta in indice.alertas:
            print(f"  {alerta}")
    else:
        print("\n Sin alertas activas.")


def ejemplo_periodizacion():
    print("\n" + "=" * 60)
    print("EJEMPLO 4: Plan Semanal Adaptativo")
    print("=" * 60)

    sesiones = crear_sesiones_prueba()
    metricas = calcular_metricas_fatiga("user_001", sesiones)
    indice = calcular_indice_riesgo("user_001", sesiones, metricas)
    plan = generar_plan_semanal("user_001", metricas, indice, semanas_desde_inicio=2)

    print(f"Semana inicio:     {plan.semana_inicio}")
    print(f"Fase:              {plan.fase.value.upper()}")
    print(f"Sesiones/semana:   {plan.sesiones_recomendadas}")
    print(f"Volumen relativo:  {plan.volumen_relativo:.0%}")
    print(f"Intensidad rel.:   {plan.intensidad_relativa:.0%}")
    print("\nEjercicios sugeridos:")
    for ej in plan.ejercicios_sugeridos:
        print(f"  • {ej}")
    print(f"\nNotas:\n{plan.notas_entrenador}")


def ejemplo_progreso():
    print("\n" + "=" * 60)
    print("EJEMPLO 5: Métricas de Progreso")
    print("=" * 60)

    sesiones = crear_sesiones_prueba()
    progreso = calcular_metricas_progreso("user_001", sesiones)

    print(f"Volumen total (28d): {progreso.volumen_total_kg:,.1f} kg")
    print(f"Intensidad RPE:      {progreso.intensidad_promedio_rpe:.1f}")
    print(f"Tendencia peso:      {progreso.tendencia_peso_corporal:+.2f} kg/semana")
    print(f"Sueño promedio:      {progreso.tendencia_sueno:.1f} h")
    print(f"Frecuencia semanal:  {progreso.frecuencia_semanal:.1f} sesiones")

    print("\nProgreso por ejercicio (90 días):")
    prog_ej = calcular_progreso_ejercicio(sesiones, "sentadilla con barra")
    if prog_ej["registros"] > 0:
        print(f"  Ejercicio:         {prog_ej['ejercicio']}")
        print(f"  Registros:         {prog_ej['registros']}")
        print(f"  e1RM inicial:      {prog_ej['e1rm_inicial']:.1f} kg")
        print(f"  e1RM actual:       {prog_ej['e1rm_actual']:.1f} kg")
        print(f"  Cambio e1RM:       {prog_ej['cambio_e1rm']:+.1f} kg")
        print(f"  Tendencia:         {prog_ej['tendencia_semanal_kg']:+.2f} kg/semana")


def ejemplo_validacion():
    print("\n" + "=" * 60)
    print("EJEMPLO 6: Validación de Entradas")
    print("=" * 60)

    datos_validos = {
        "usuario_id": "user_001",
        "fecha": str(date.today()),
        "ejercicios": [
            {"nombre": "Sentadilla", "series": 5, "repeticiones": 5,
             "peso_kg": 100.0, "rpe": 8.0}
        ],
        "horas_sueno": 7.5,
        "peso_corporal_kg": 80.0,
    }
    resultado = validar_sesion(datos_validos)
    print(f"Sesión válida:     {resultado.valido}")

    datos_invalidos = {
        "usuario_id": "",
        "fecha": "2099-01-01",
        "ejercicios": [
            {"nombre": "", "series": -1, "repeticiones": 5, "peso_kg": 100.0}
        ],
        "horas_sueno": 30,
    }
    datos_sanitizados = sanitizar_sesion_dict(datos_invalidos)
    resultado_inv = validar_sesion(datos_sanitizados)
    print(f"Sesión inválida:   {resultado_inv.valido}")
    print("Errores detectados:")
    for error in resultado_inv.errores:
        print(f"  ✗ {error}")


def ejemplo_dashboard():
    print("\n" + "=" * 60)
    print("EJEMPLO 7: Dashboard Completo")
    print("=" * 60)

    sesiones = crear_sesiones_prueba()
    datos = generar_datos_dashboard("user_001", sesiones)

    print(f"Usuario:           {datos['usuario_id']}")
    print(f"Fecha:             {datos['fecha']}")
    print(f"\n📊 Métricas de fatiga:")
    mf = datos["metricas_fatiga"]
    print(f"  ACWR: {mf['acwr']:.3f} | TSB: {mf['tsb']:.1f} | Zona: {mf['zona_riesgo']}")
    print(f"\n🔴 Índice de Riesgo: {datos['indice_riesgo']['score']:.3f} ({datos['indice_riesgo']['zona']})")
    print(f"\n📅 Plan semanal: {datos['plan_semanal']['fase'].upper()} — "
          f"{datos['plan_semanal']['sesiones_recomendadas']} sesiones")
    print(f"\n📈 Volumen últimos 28d: {datos['metricas_progreso']['volumen_total_kg']:,.1f} kg")
    print(f"   Sesiones recientes:  {len(datos['sesiones_recientes'])}")
    print(f"   Puntos gráfica ATL:  {len(datos['grafica_fatiga'])}")
    print(f"   Alertas activas:     {len(datos['alertas_activas'])}")
    print(f"   Sueño promedio 7d:   {datos['sueno_promedio_7d']:.1f} h")


# ──────────────────────────────────────────────
#  Punto de entrada
# ──────────────────────────────────────────────

if __name__ == "__main__":
    print("🏋️  ASIP — Adaptive Strength Intelligence Platform")
    print("    Data Processing Examples — StrengthLabs 2026")

    ejemplo_carga()
    ejemplo_fatiga()
    ejemplo_riesgo()
    ejemplo_periodizacion()
    ejemplo_progreso()
    ejemplo_validacion()
    ejemplo_dashboard()

    print("\n" + "=" * 60)
    print("Todos los ejemplos ejecutados correctamente.")
    print("=" * 60)
