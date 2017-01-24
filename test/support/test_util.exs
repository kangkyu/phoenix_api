
defmodule PhoenixAPI.TestUtil do
  @no_mock_evar Application.fetch_env!(:phoenix_api, :no_mock_evar)
  @no_mock System.get_env @no_mock_evar

  def no_mock(from_file) do
    IO.puts "\n... in file '#{from_file}'\n" <>
      "  Set env var '#{@no_mock_evar}' to disable mocking\n" <>
      "  Currently set to '#{@no_mock}'"

    @no_mock
  end
end
