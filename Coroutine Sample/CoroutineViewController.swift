//
//  SecondViewController.swift
//  Coroutine Sample
//
//  Created by Jeff Lockhart on 5/1/20.
//  Copyright © 2020 Jeff Lockhart. All rights reserved.
//

import UIKit
import coswift


// MARK: Constants


private let POKEMON_NAME = "psyduck"
private let ANIMATION_DURATION = 0.5


class CoroutineViewController: UIViewController {


    // MARK: - Views


    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet var images: [UIImageView]!


    // MARK: - Fields


    private let api = CoroutinePokeApi()
    private var animationCoroutine: Coroutine?


    // MARK: - Lifecycle


    override func viewDidLoad() {
        super.viewDidLoad()
        populateUi()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimation()
    }


    // MARK: - API


    private func populateUi() {
        co_launch {
            guard let pokemon = try self.co_getPokemon() else { return }
            self.nameLabel.text = pokemon.name
            try self.co_getImages(for: pokemon)
        }
    }

    private func co_getPokemon() throws -> Pokemon? {
        let result = try await(promise: api.co_getPokemon(named: POKEMON_NAME))
        switch result {
        case .fulfilled(let pokemon):
            return pokemon
        case .rejected(let error):
            print(error)
            return nil
        }
    }

    private func co_getImages(for pokemon: Pokemon) throws {
        images[0].image = try co_getImage(type: .frontDefault, for: pokemon)
        images[1].image = try co_getImage(type: .frontShiny, for: pokemon)
        images[2].image = try co_getImage(type: .backDefault, for: pokemon)
        images[3].image = try co_getImage(type: .backShiny, for: pokemon)
    }

    private func co_getImage(type: CoroutinePokeApi.ImageType, for pokemon: Pokemon) throws -> UIImage? {
        let result = try await(promise: api.co_getImage(type: type, for: pokemon))
        switch result {
        case .fulfilled(let image):
            return image
        case .rejected(let error):
            print(error)
            return nil
        }
    }


    // MARK: - Animation


    private func startAnimation() {
        animationCoroutine = co_launch {
            var idx = 0
            while true {
                for i in 0..<4 {
                    self.images[i].isHidden = i != idx
                }
                idx += 1
                idx %= 4
                try co_delay(ANIMATION_DURATION)
            }
        }
    }

    private func stopAnimation() {
        animationCoroutine?.cancel()
        animationCoroutine = nil
    }


    // MARK: - Button


    @IBAction func onButtonPress() {
        let red = randomColorValue()
        let green = randomColorValue()
        let blue = randomColorValue()
        view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 0.8)
    }

    private func randomColorValue() -> CGFloat {
        return CGFloat(Float.random(in: 0 ..< 1))
    }
}
