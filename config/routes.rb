Rails.application.routes.draw do
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  mount Blacklight::Citeproc::Engine => '/'

  root 'bento#home'
  get '/search' => 'bento#index'

  get '/catalog', to: 'catalog#index'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  resource :articles, only: [:index], as: 'articles', path: '/articles', controller: 'articles' do
    concerns :searchable
    concerns :range_searchable
  end

  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns [:exportable]
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # Static pages
  get '/about' => 'static#about'
  # get '/more' => 'catalog#more'

  # Article view
  get 'articles/:db/:id' => 'articles#show', :constraints => { id: %r{[^/]+} }

  # Articles don't have their own range limit
  get 'articles/range_limit', to: redirect(path: '/catalog/range_limit')

  mount FieldTest::Engine, at: "field_test"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
