defmodule Datos do
  @moduledoc """
  Módulo que contiene las colecciones de confeccionistas, líneas y lotes.
  """

  def confeccionistas do
    [
      %{codigo: "C01", nombre: "María Elena Ríos", alquiler: true},
      %{codigo: "C02", nombre: "Andrés Salazar", alquiler: false},
      %{codigo: "C03", nombre: "Carol Gomez", alquiler: true},
      %{codigo: "C04", nombre: "David Hernandez", alquiler: false},
      %{codigo: "C05", nombre: "Elena Torres", alquiler: true},
      %{codigo: "C06", nombre: "Fernando Lopez", alquiler: false},
      %{codigo: "C07", nombre: "Robinson Arias", alquiler: true},
      %{codigo: "C08", nombre: "Hugo Ramirez", alquiler: false},
      %{codigo: "C09", nombre: "Isabel Vargas", alquiler: false},
      %{codigo: "C10", nombre: "Jorge Velasquez", alquiler: true}
    ]
  end

  def lineas do
    [
      %{id: "L1", nombre: "Línea Norte", puestos: 6},
      %{id: "L2", nombre: "Línea Central", puestos: 4},
      %{id: "L3", nombre: "Línea Sur", puestos: 5},
      %{id: "L4", nombre: "Línea Oriente", puestos: 5}
    ]
  end

  def lotes do
    validos = for dia <- 1..6,
                  c <- ["C01", "C02", "C03", "C04", "C05", "C06", "C07", "C08", "C09", "C10"],
                  linea <- ["L1", "L2", "L3", "L4"],

                  rem(:erlang.phash2({dia, c, linea}), 3) == 0 do

      prendas = 1 + rem(:erlang.phash2({dia, c}), 180)
      enteros_def = rem(:erlang.phash2({linea, dia, c}), 101)
      decimales_def = rem(:erlang.phash2({c, dia}), 10) / 10.0
      defectos = min(100.0, enteros_def + decimales_def)

      %{confeccionista: c, linea: linea, dia: dia, prendas: prendas, defectos: defectos}
    end

    invalidos = [
      # :confeccionista_desconocido
      %{confeccionista: "C99", linea: "L1", dia: 1, prendas: 50, defectos: 1.0},
      %{confeccionista: "CX", linea: "L2", dia: 2, prendas: 60, defectos: 2.0},

      # :linea_desconocida
      %{confeccionista: "C01", linea: "L9", dia: 1, prendas: 50, defectos: 1.0},
      %{confeccionista: "C02", linea: "LX", dia: 3, prendas: 70, defectos: 0.5},

      # :dia_invalido
      %{confeccionista: "C01", linea: "L1", dia: 0, prendas: 50, defectos: 1.0},
      %{confeccionista: "C02", linea: "L2", dia: 7, prendas: 60, defectos: 2.0},

      # :prendas_fuera_de_rango
      %{confeccionista: "C03", linea: "L1", dia: 1, prendas: 0, defectos: 1.0},
      %{confeccionista: "C04", linea: "L2", dia: 2, prendas: 181, defectos: 1.0},

      # :porcentaje_invalido
      %{confeccionista: "C05", linea: "L1", dia: 1, prendas: 50, defectos: -0.5},
      %{confeccionista: "C06", linea: "L2", dia: 2, prendas: 50, defectos: 100.1}
    ]

    validos ++ invalidos
  end
end
