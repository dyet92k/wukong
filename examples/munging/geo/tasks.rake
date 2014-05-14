require_relative('../../rake_helper')

Pathname.register_paths(
  geo_data:                  [:data, 'geo'],
  geo_work:                  [:work, 'geo'],
  geo_gold:                  [:gold, 'geo'],
  geo_code:                  File.dirname(__FILE__),
  #
  iso_3166:                  [:geo_data, 'iso_codes', "iso_3166.tsv"   ],
  geonames_countries:        [:geo_data, 'geonames',  "geonames_countries.json"   ],
  #
  countries_json:            [:geo_gold, "countries.json"   ],
  countries_tsv:             [:geo_gold, "countries.tsv"   ],
  country_gazette:           [:geo_gold, "country_gazette.tsv"   ],
  )

chain :geo do
  code_files = FileList[Pathname.of(:geo_code, '*.rb').to_s]
  chain(:countries) do

    task(:load) do
      require 'wu/model/indexable'
      require 'wu/model/reconcilable'
      require('wu/geo/models')
      require('wu/geo/geo_json')
      require('wu/geo/geonames_models')
      require('wu/geo/iso_codes')
      require_relative('./reconcile_countries')
      CountryReconciler.load_reconciled_countries
    end

    # desc 'load the ISO 3166 countries'
    # task(:countries_iso_3166, after: [code_files, :force]) do |dest|
    #   require_relative('./iso_codes')
    #   p Wukong::Data::CountryCode.for_any_name('Bolivia')
    # end
    #
    # step(:geonames_countries, doc: 'load the Geonames countries',
    #   invoke: 'geo:countries:load',
    #   # , after: [code_files, :force]
    #   ) do |dest|
    #   Wukong::Data::GeonamesGeoJson.load(:geonames_countries)
    # end

    desc 'Add the iso_codes data to the geonames countries'
    create_file(:countries_json, invoke: 'geo:countries:load', after: [code_files, :force]) do |dest|
      Geo::Country.values.each do |country|
        dest << country.to_json << "\n"
      end
    end

    create_file(:countries_tsv, invoke: 'geo:countries:load', after: [code_files, :force]) do |dest|
      Geo::Country.values.each do |country|
        dest << country.to_tsv << "\n"
      end
    end

    desc 'Add the iso_codes data to the geonames countries'
    create_file(:country_gazette, invoke: 'geo:countries:load', after: [code_files, :force]) do |dest|
      Geo::Country.values.each do |ct|
        ct.names.each do |alt_name|
          dest << [ct.country_id, ct.country_al3id, ct.country_numid,
            ct.tld_id, ct.geonames_id,
            ct.name,
            Geo::Place.slugify_name(alt_name), alt_name
          ].join("\t") << "\n"
        end
      end
    end

  end
end

task :default => [
  'geo:countries',
]
