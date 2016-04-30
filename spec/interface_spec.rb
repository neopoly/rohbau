require 'spec_helper'
require 'rohbau/interface'
require 'bound'

describe Rohbau::Interface do
  let(:interface) { Rohbau::Interface.instance }

  after do
    interface.clear_stubs
  end

  module FakeDomain
    class Request
    end

    module UseCases
      class FakeUseCase
        Input = Bound.required :super_important_information
        Success = Bound.required :message
        Error = Bound.required :message

        def initialize(request, input)
          @request = request
          @input = input
        end

        def call
          Success.new :message => "original usecase output message"
        end
      end
    end
  end

  it 'is a singleton' do
    assert interface === Rohbau::Interface.instance
  end

  it 'calls a use case' do
    result = interface.fake_domain :fake_use_case,
      :super_important_information => "23"
    assert_kind_of FakeDomain::UseCases::FakeUseCase::Success, result
    assert_equal 'original usecase output message', result.message
  end

  it 'raises if the domain is unknown' do
    assert_raises ArgumentError do
      interface.really_fake_domain :equally_fake_use_case
    end
  end

  it 'returns success for all use_cases when run in stub mode' do
    result = interface.fake_domain :fake_use_case,
      :stub_result => { :message => 'a different message' }

    assert_kind_of FakeDomain::UseCases::FakeUseCase::Success, result
    assert_equal 'a different message', result.message
  end

  it 'can return other result types' do
    interface.fake_domain :fake_use_case,
      :stub_type => :Error,
      :stub_result => {
        :message => "error"
      }

    result = interface.fake_domain :fake_use_case

    assert_kind_of FakeDomain::UseCases::FakeUseCase::Error, result
    assert_equal 'error', result.message
  end

  it 'returns subsequent calls to the same use case as stubs' do
    interface.fake_domain :fake_use_case,
      :stub_result => { :message => 'a different message' }

    result = interface.fake_domain :fake_use_case,
      :super_important_information => "23"

    assert_kind_of FakeDomain::UseCases::FakeUseCase::Success, result
    assert_equal 'a different message', result.message
  end

  it 'records passed arguments by use_case' do
    interface.fake_domain :fake_use_case,
      :super_important_information => "23"

    result = interface.calls[:fake_use_case][:super_important_information]

    assert_equal "23", result
  end

  it 'records number of unstubbed calls to each use_case' do
    interface.fake_domain :fake_use_case,
      :super_important_information => "23"

    interface.fake_domain :fake_use_case,
      :super_important_information => "56"

    interface.fake_domain :fake_use_case,
      :stub_result => { :message => 'message' }

    assert_equal 2, interface.call_count[:fake_use_case]
  end

  it 'can clear all stubbed results' do
    interface.fake_domain :fake_use_case,
      :stub_result => { :message => 'a different message' }

    result = interface.fake_domain :fake_use_case
    assert_equal 'a different message', result.message

    interface.clear_stubs

    result = interface.fake_domain :fake_use_case,
      :super_important_information => "23"
    refute_equal 'a different message', result.message
    assert_equal 'original usecase output message', result.message
  end
end
