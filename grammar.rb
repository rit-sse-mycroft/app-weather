require 'srgs'

module WeatherGrammar
  include Srgs::DSL

  extend self

  grammar 'topLevel' do
    private_rule 'riseset' do
      one_of do
        item 'rise'
        item 'set'
      end
    end

    private_rule 'days' do
      one_of do
        item 'today'
        item 'tomorrow'
        item 'currently'
      end
    end

    public_rule 'weather' do
      item 'what is the weather'
      reference '#days'
      tag 'out.day=rules.days;'
    end

    public_rule 'sun' do
      reference '#sunprefix'
      tag 'out.prefix=rules.sunprefix'
      item 'sun'
      reference '#riseset'
      tag 'out.rise_or_set=rules.riseset;'
      reference '#days'
      tag 'out.day=rules.days;'
    end

    private_rule 'sunprefix' do
      one_of do
        item 'when is'
        item 'how long until'
      end
    end

    public_rule 'topLevel' do
      item 'Mycroft'
      one_of do
        reference_item '#weather'
        reference_item '#sun'
      end
    end
  end
end