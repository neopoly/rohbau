require 'minitest/autorun'

describe 'Verify examples' do
  let(:fixture_dir) do
    Pathname.new(File.dirname(__FILE__))
  end
  let(:expected_output) do
    File.read(fixture_dir.join('examples.txt'))
  end

  it 'verifies examples' do
    actual, error = capture_subprocess_io do
      system 'rake examples'
    end

    assert_possibly_equal actual, expected_output
    assert_equal '', error
  end

  private

  def assert_possibly_equal(exp, act)
    assert_equal mu_pp_for_diff(exp), mu_pp_for_diff(act)
  end
end
