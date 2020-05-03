//
//  FirstViewController.swift
//  Coroutine Sample
//
//  Created by Jeff Lockhart on 5/1/20.
//  Copyright © 2020 Jeff Lockhart. All rights reserved.
//

import UIKit

// MARK: Constants


private let POKEMON_NAME = "ditto"
private let ANIMATION_DURATION = 0.5


class CallbackViewController: UIViewController {


    // MARK: - Views


    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet var images: [UIImageView]!


    // MARK: - Fields


    private let api = CallbackPokeApi()
    private var animationTask: DispatchWorkItem?
    private var animationIdx = 0


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
        getPokemon { [weak self] pokemon in
            guard let pokemon = pokemon else { return }
            self?.nameLabel.text = pokemon.name
            self?.getImages(for: pokemon)
        }
    }

    private func getPokemon(completion: @escaping (Pokemon?) -> Void) {
        api.getPokemon(named: POKEMON_NAME) { (pokemon, error) in
            if let error = error {
                print(error)
            }
            completion(pokemon)
        }
    }

    private func getImages(for pokemon: Pokemon) {
        getImage(type: .frontDefault, for: pokemon) { [weak self] image in
            self?.images[0].image = image
        }
        getImage(type: .frontShiny, for: pokemon) { [weak self] image in
            self?.images[1].image = image
        }
        getImage(type: .backDefault, for: pokemon) { [weak self] image in
            self?.images[2].image = image
        }
        getImage(type: .backShiny, for: pokemon) { [weak self] image in
            self?.images[3].image = image
        }
    }

    private func getImage(type: CallbackPokeApi.ImageType, for pokemon: Pokemon, completion: @escaping (UIImage?) -> Void) {
        api.getImage(type: type, for: pokemon) { (image, error) in
            if let error = error {
                print(error)
            }
            completion(image)
        }
    }


    // MARK: - Animation


    private func startAnimation() {
        animationTask = DispatchWorkItem {
            for i in 0..<4 {
                self.images[i].isHidden = i != self.animationIdx
            }
            self.animationIdx += 1
            self.animationIdx %= 4
            if let animationTask = self.animationTask {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + ANIMATION_DURATION, execute: animationTask)
            }
        }
        animationTask?.perform()
    }

    private func stopAnimation() {
        animationTask?.cancel()
        animationTask = nil
        animationIdx = 0
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
