//
//  CallbackPokeApi.swift
//  Coroutine Sample
//
//  Created by Jeff Lockhart on 5/1/20.
//  Copyright © 2020 Jeff Lockhart. All rights reserved.
//

import Foundation
import UIKit

class CallbackPokeApi {

    private let baseUrl = URL(string: "https://pokeapi.co/api/v2/")!

    func getPokemon(named name: String, completion: @escaping (Pokemon?, Error?) -> Void) {

        let url = URL(string: "pokemon/\(name)/", relativeTo: self.baseUrl)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in

            guard data != nil, error == nil else { completion(nil, error); return }

            DispatchQueue.global().async {

                do {
                    let pokemon = try JSONDecoder().decode(Pokemon.self, from: data!)
                    DispatchQueue.main.async {
                        completion(pokemon, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }

    func getImage(type: ImageType, for pokemon: Pokemon, completion: @escaping (UIImage?, Error?) -> Void) {

        guard let urlString = type.url(for: pokemon) else {
            DispatchQueue.main.async {
                completion(nil, PokemonError.noImage("No \(type) image for \(pokemon.name)"))
            }
            return
        }

        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(nil, PokemonError.invalidImageUrl("Invalid URL \(urlString) for \(type) image for \(pokemon.name)"))
            }
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in

            guard data != nil, error == nil else { completion(nil, error); return }

            DispatchQueue.global().async {

                let image = UIImage(data: data!)

                DispatchQueue.main.async {

                    guard let image = image else {
                        completion(nil, PokemonError.notAnImage("Data not an image at URL \(urlString) for \(type) image for \(pokemon.name)"))
                        return
                    }
                    completion(image, nil)
                }
            }
        }
        task.resume()
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
        case noImage(String)
        case invalidImageUrl(String)
        case notAnImage(String)
    }
}
