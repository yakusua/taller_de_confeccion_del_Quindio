defmodule TallerConfeccion do
  @tarifa_base_prenda 3200
  @meta_diaria_taller 600
  @dias_produccion 1..6
  @max_prendas_lote 180
  @prendas_diarias_bonificacion 120
  @bonificacion_diaria 18000
  @alquiler_maquina_dia 15000

  def tarifa_base_prenda, do: @tarifa_base_prenda
  def meta_diaria_taller, do: @meta_diaria_taller
  def dias_produccion, do: @dias_produccion
  def max_prendas_lote, do: @max_prendas_lote
  def prendas_diarias_bonificacion, do: @prendas_diarias_bonificacion
  def bonificacion_diaria, do: @bonificacion_diaria
  def alquiler_maquina_dia, do: @alquiler_maquina_dia
end
