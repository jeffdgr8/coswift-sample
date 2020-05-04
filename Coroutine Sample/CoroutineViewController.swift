//
//  CoroutineViewController.swift
//  Coroutine Sample
//
//  Created by Jeff Lockhart on 5/1/20.
//  Copyright © 2020 Jeff Lockhart. All rights reserved.
//

import UIKit
import coswift


// MARK: Constants


private let DEFAULT_POKEMON_NAME = "psyduck"
private let ANIMATION_DURATION = 0.5


class CoroutineViewController: UIViewController {


    // MARK: - Views


    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet var images: [UIImageView]!


    // MARK: - Fields


    private let api = CoroutinePokeApi()
    private var animationCoroutine: Coroutine?


    // MARK: - Lifecycle


    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.text = DEFAULT_POKEMON_NAME
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
        co_launch { [weak self] in
            guard let pokemon = try self?.co_getPokemon() else {
                try self?.co_invalidPokemon()
                return
            }
            try self?.co_getImages(for: pokemon)
        }
    }

    private func co_getPokemon() throws -> Pokemon? {
        guard let name = nameField.text else { return nil }
        let result = try await(promise: api.co_getPokemon(named: name))
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

    private func co_invalidPokemon() throws {
        let textColor = self.nameField.textColor
        self.nameField.textColor = UIColor.red
        try co_delay(ANIMATION_DURATION)
        self.nameField.textColor = textColor
    }


    // MARK: - Animation


    private func startAnimation() {
        animationCoroutine = co_launch { [weak self] in
            guard let self = self else { return }

            var idx = 0
            while Coroutine.isActive() {
                for i in 0..<4 {
                    self.images[i].isHidden = i != idx
                }

                repeat {
                    idx += 1
                    idx %= 4
                } while idx != 0 && self.images[idx].image == nil

                try co_delay(ANIMATION_DURATION)
            }
        }
    }

    private func stopAnimation() {
        animationCoroutine?.cancel()
        animationCoroutine = nil
    }


    // MARK: - Actions


    @IBAction func onButtonPress() {
        nameField.resignFirstResponder()
        let red = randomColorValue()
        let green = randomColorValue()
        let blue = randomColorValue()
        view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 0.8)
    }

    private func randomColorValue() -> CGFloat {
        return CGFloat(Float.random(in: 0 ..< 1))
    }

    @IBAction func onNameChanged(_ sender: Any) {
        nameField.resignFirstResponder()
        populateUi()
    }
}
