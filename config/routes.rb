Rails.application.routes.draw do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

    namespace :api do
        namespace :hl7cda do
            resources :fhir_prescription_generators, only: %i[create]
        end
    end
end
