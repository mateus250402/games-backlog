{-# LANGUAGE OverloadedStrings #-}

module Pages.Login where

import Data.Text (Text)
import Lucid

loginPage :: Maybe Text -> Html ()
loginPage maybeError = html_ [lang_ "pt-br"] $ do
    head_ $ do
        title_ "Login - Games Backlog"
        meta_ [charset_ "utf-8"]
        meta_ [name_ "viewport", content_ "width=device-width, initial-scale=1"]
        link_ [href_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css", rel_ "stylesheet"]
    
    body_ $ do
        nav_ [class_ "navbar navbar-expand-lg navbar-dark bg-primary"] $ do
            div_ [class_ "container"] $ do
                a_ [class_ "navbar-brand", href_ "/"] "🎮 Games Backlog"
                div_ [class_ "navbar-nav ms-auto"] $ do
                    a_ [class_ "nav-link", href_ "/register"] "Registrar"
                    a_ [class_ "nav-link", href_ "/"] "Início"

        div_ [class_ "container"] $ do
            div_ [class_ "row justify-content-center"] $ do
                div_ [class_ "col-md-6 col-lg-4"] $ do
                    div_ [class_ "card mt-5 shadow bg-light"] $ do
                        div_ [class_ "card-header text-center bg-primary text-white"] $ do
                            h4_ [class_ "mb-0"] "🔐 Fazer Login"
                        
                        div_ [class_ "card-body p-4"] $ do
                            case maybeError of
                                Just errorMessage ->
                                    div_ [class_ "alert alert-warning shadow-sm border-0 rounded-4 px-4 py-3", role_ "alert"] $ do
                                        h5_ [class_ "alert-heading mb-2"] "Nao foi possivel entrar"
                                        p_ [class_ "mb-2"] "Confira se o e-mail e a senha estao corretos e tente novamente."
                                        p_ [class_ "mb-0 small"] (toHtml errorMessage)
                                Nothing -> mempty

                            form_ [method_ "post", action_ "/login"] $ do
                                div_ [class_ "mb-3"] $ do
                                    label_ [for_ "email", class_ "form-label"] "E-mail"
                                    input_ [type_ "email", class_ "form-control", id_ "email", 
                                           name_ "email", required_ "", placeholder_ "Digite seu e-mail"]
                                
                                div_ [class_ "mb-3"] $ do
                                    label_ [for_ "password", class_ "form-label"] "Senha"
                                    input_ [type_ "password", class_ "form-control", id_ "password", 
                                           name_ "password", required_ "", placeholder_ "Digite sua senha"]
                                
                                div_ [class_ "d-grid"] $ do
                                    button_ [type_ "submit", class_ "btn btn-primary"] "Entrar"
                        
                        div_ [class_ "card-footer text-center bg-primary"] $ do
                            span_ [class_ "text-light"] "Não tem conta? "
                            a_ [href_ "/register", class_ "text-white text-decoration-none"] "Registre-se"
                            br_ []
                            a_ [href_ "/", class_ "text-muted text-decoration-none"] "← Voltar ao início"
        
        script_ [src_ "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"] ("" :: Html ())
