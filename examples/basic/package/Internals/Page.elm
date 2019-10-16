module Internals.Page exposing
    ( Page, Recipe, Bundle
    , Static, static
    , Sandbox, sandbox
    , Element, element
    )

{-|

@docs Page, Recipe, Bundle

@docs Static, static

@docs Sandbox, sandbox

@docs Element, element

-}

import Html exposing (Html)


type alias Page pageModel pageMsg model msg =
    { toModel : pageModel -> model
    , toMsg : pageMsg -> msg
    }
    -> Recipe pageModel pageMsg model msg


type alias Recipe pageModel pageMsg model msg =
    { init : ( model, Cmd msg )
    , update : pageMsg -> pageModel -> ( model, Cmd msg )
    , bundle : pageModel -> Bundle msg
    }


type alias Bundle msg =
    { view : Html msg
    , subscriptions : Sub msg
    }



-- STATIC


type alias Static =
    { view : Html Never
    }


static :
    Static
    -> Page () Never model msg
static page { toModel, toMsg } =
    { init = ( toModel (), Cmd.none )
    , update = \_ model -> ( toModel model, Cmd.none )
    , bundle =
        \_ ->
            { view = Html.map toMsg page.view
            , subscriptions = Sub.none
            }
    }



-- SANDBOX


type alias Sandbox pageModel pageMsg =
    { init : pageModel
    , update : pageMsg -> pageModel -> pageModel
    , view : pageModel -> Html pageMsg
    }


sandbox :
    Sandbox pageModel pageMsg
    -> Page pageModel pageMsg model msg
sandbox page { toModel, toMsg } =
    { init = ( toModel page.init, Cmd.none )
    , update =
        \msg model ->
            ( page.update msg model |> toModel
            , Cmd.none
            )
    , bundle =
        \model ->
            { view = page.view model |> Html.map toMsg
            , subscriptions = Sub.none
            }
    }



-- SANDBOX


type alias Element pageModel pageMsg =
    { init : ( pageModel, Cmd pageMsg )
    , update : pageMsg -> pageModel -> ( pageModel, Cmd pageMsg )
    , view : pageModel -> Html pageMsg
    , subscriptions : pageModel -> Sub pageMsg
    }


element :
    Element pageModel pageMsg
    -> Page pageModel pageMsg model msg
element page { toModel, toMsg } =
    { init = page.init |> Tuple.mapBoth toModel (Cmd.map toMsg)
    , update =
        \msg model ->
            page.update msg model
                |> Tuple.mapBoth toModel (Cmd.map toMsg)
    , bundle =
        \model ->
            { view = page.view model |> Html.map toMsg
            , subscriptions = Sub.none
            }
    }
