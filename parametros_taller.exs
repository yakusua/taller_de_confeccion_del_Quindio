defmodule ParametrosTaller do
  @moduledoc """
  Este módulo contiene los parámetros y constantes del taller de confección, como tarifas, metas y límites.
  por favor, es muy importante que si se utilizaran estos datos, no los quemen en codigo, accedan a este modulo para obtenerlos,
  que en caso de cambiar, se tendria que revisar todo el codigo
  """
  @tarifa_base_prenda 3200
  @meta_diaria_taller 600
  @dias_produccion 1..6
  @max_prendas_lote 180
  @prendas_diarias_bonificacion 120
  @bonificacion_diaria 18000
  @alquiler_maquina_dia 15000

  @doc """
  estas funciones acceden a las constantes
  """
  def tarifa_base_prenda, do: @tarifa_base_prenda
  def meta_diaria_taller, do: @meta_diaria_taller
  def dias_produccion, do: @dias_produccion
  def max_prendas_lote, do: @max_prendas_lote
  def prendas_diarias_bonificacion, do: @prendas_diarias_bonificacion
  def bonificacion_diaria, do: @bonificacion_diaria
  def alquiler_maquina_dia, do: @alquiler_maquina_dia
end
