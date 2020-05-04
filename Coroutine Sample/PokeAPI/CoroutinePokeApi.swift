//
//  CoroutinePokeApi.swift
//  Coroutine Sample
//
//  Created by Jeff Lockhart on 5/1/20.
//  Copyright © 2020 Jeff Lockhart. All rights reserved.
//

import Foundation
import UIKit
import coswift
import cokit

class CoroutinePokeApi {

    private let baseUrl = URL(string: "https://pokeapi.co/api/v2/")!

    func co_getPokemon(named name: String) -> Promise<Pokemon> {
        return Promise<Pokemon>(constructor: { (fulfill, reject) in
            co_launch_onqueue(DispatchQueue.global()) {

                guard let url = URL(string: "pokemon/\(name.lowercased())/", relativeTo: self.baseUrl) else {
                    reject(PokemonError.invalidName("Invalid Pokemon name \(name)"))
                    return
                }

                var error: NSError? = nil
                let data: Data? = URLSession.shared.co_dataTask(with: url, response: nil, error: &error)

                guard data != nil, error == nil else { reject(error!); return }

                do {
                    let pokemon = try JSONDecoder().decode(Pokemon.self, from: data!)
                    fulfill(pokemon)
                } catch {
                    reject(error)
                }
            }
        })
    }

    func co_getImage(type: ImageType, for pokemon: Pokemon) -> Promise<UIImage> {
        return Promise<UIImage> { (fulfill, reject) in
            co_launch_onqueue(DispatchQueue.global()) {

                guard let urlString = type.url(for: pokemon) else {
                    reject(PokemonError.noImage("No \(type) image for \(pokemon.name)"))
                    return
                }

                guard let url = URL(string: urlString) else {
                    reject(PokemonError.invalidImageUrl("Invalid URL \(urlString) for \(type) image for \(pokemon.name)"))
                    return
                }

                var error: NSError? = nil
                let data: Data? = URLSession.shared.co_dataTask(with: url, response: nil, error: &error)

                guard data != nil, error == nil else { reject(error!); return }

                guard let image = UIImage(data: data!) else {
                    reject(PokemonError.notAnImage("Data not an image at URL \(urlString) for \(type) image for \(pokemon.name)"))
                    return
                }

                fulfill(image)
            }
        }
    }

    enum ImageType {
        case frontDefault
        case frontShiny
        case backDefault
        case backShiny

        func url(for pokemon: Pokemon) -> String? {
            switch self {
            case .frontDefault:
                return pokemon.sprites.frontDefault
            case .frontShiny:
                return pokemon.sprites.frontShiny
            case .backDefault:
                return pokemon.sprites.backDefault
            case .backShiny:
                return pokemon.sprites.backShiny
            }
        }
    }

    enum PokemonError: Error {
        case invalidName(String)
        case noImage(String)
        case invalidImageUrl(String)
        case notAnImage(String)
    }
}
