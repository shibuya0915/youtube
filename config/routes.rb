Rails.application.routes.draw do
  # カテゴリIDがある場合もindexアクションで処理し、パラメータとして受け取る
  resources :videos

  # トップページとして設定
  root 'videos#index'
end
