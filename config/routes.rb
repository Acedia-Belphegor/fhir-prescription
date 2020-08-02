Rails.application.routes.draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    namespace :api do
        namespace :hl7cda do
            resources :cda_fhir_prescription_generators, only: %i[create]
            resources :cda_fhir_dispensing_generators, only: %i[create]
        end
        namespace :hl7v2 do
            resources :v2_fhir_prescription_generators, only: %i[create]
        end
    end
end
