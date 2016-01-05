require 'spec_helper'
require 'pathname'
require 'active_support/core_ext/object/blank'

describe UniqueHtmlExtractonator do
  it 'has a version number' do
    expect(UniqueHtmlExtractonator::VERSION).not_to be nil
  end

  let(:root_path) { Pathname.new File.realpath('.', File.dirname(__FILE__)) }

  def fixture_read(file)
    File.open(root_path.join("fixtures/#{file}")).read
  end

  describe 'html extraction' do
    let(:reference_html) { fixture_read 'common1.html' }
    let(:html) { fixture_read self.class.metadata[:description] }
    let(:extractor) { UniqueHtmlExtractonator::Extractor.new(reference_html: reference_html, html: html) }
    subject { extractor.extract }

    context 'common1.html' do
      let(:reference_html) { fixture_read 'common3.html' }
      it 'should be parsed' do is_expected.to eq(fixture_read 'common1.extracted.html') end
    end
    context 'common2.html' do
      it 'should be parsed' do is_expected.to eq(fixture_read 'common2.extracted.html') end
    end
    context 'common3.html' do
      it 'should be parsed' do is_expected.to eq(fixture_read 'common3.extracted.html') end
    end
  end
end
