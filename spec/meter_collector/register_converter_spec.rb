require 'spec_helper'

describe MeterCollector::RegisterConverter do
  subject { described_class.new(format).convert_registers(input) }

  describe 'registers representing integers' do
    let(:format) { :integer }

    context 'when passing single register' do
      let(:input) { [12_345] }

      it 'returns value of the register' do
        is_expected.to eq(12_345)
      end
    end

    context 'when passing multiple registers' do
      let(:input) { [1, 0] }

      it 'registers are combined' do
        is_expected.to eq(2**16)
      end
    end
  end

  describe 'registers representing floating point numbers' do
    let(:format) { :float }
    let(:input) do
      # Converting the input number to representation we would find
      # in multiple Modbus registers (each 16 Bit wide)
      [input_number].pack('F')
                    .bytes
                    .each_slice(2)
                    .map { |msb, lsb| ((msb || 0) << 8) + lsb }
    end

    let(:input_number) { 123.4 }

    it 'converts the result to a float' do
      is_expected.to eq(input_number)
    end
  end
end
