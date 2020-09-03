Rails.application.routes.draw do
    root to: "fhir_testers#index"

    resources :fhir_testers do
        member do
        end
    end
    
    namespace :api do
        namespace :hl7 do
            resources :cda_fhir_prescription_generators, only: %i[create]
            resources :cda_fhir_dispensing_generators, only: %i[create]
            resources :v2_fhir_prescription_generators, only: %i[create]
        end
        namespace :jahis do
            resources :qr_fhir_prescription_generators, only: %i[create]
        end
    end
end
