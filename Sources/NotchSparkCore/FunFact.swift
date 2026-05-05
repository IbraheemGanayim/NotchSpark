import Foundation

public struct FunFact: Equatable, Hashable, Sendable {
    public let text: String
    public let symbolName: String
    public let paletteIndex: Int

    public init(text: String, symbolName: String, paletteIndex: Int) {
        self.text = text
        self.symbolName = symbolName
        self.paletteIndex = paletteIndex
    }
}

public extension FunFact {
    static let defaultFacts: [FunFact] = [
        FunFact(text: "A day on Venus is longer than its year.", symbolName: "sparkles", paletteIndex: 0),
        FunFact(text: "Octopuses have blue blood and three hearts.", symbolName: "drop.fill", paletteIndex: 1),
        FunFact(text: "Bananas are berries, but strawberries are not.", symbolName: "leaf.fill", paletteIndex: 2),
        FunFact(text: "Honey never spoils when it is sealed well.", symbolName: "hexagon.fill", paletteIndex: 3),
        FunFact(text: "Sharks are older than trees by about 50 million years.", symbolName: "wave.3.right", paletteIndex: 4),
        FunFact(text: "The Eiffel Tower can grow taller on hot days.", symbolName: "thermometer.sun.fill", paletteIndex: 5),
        FunFact(text: "Space smells faintly like seared steak to astronauts.", symbolName: "moon.stars.fill", paletteIndex: 0),
        FunFact(text: "A cloud can weigh more than a million pounds.", symbolName: "cloud.fill", paletteIndex: 1),
        FunFact(text: "Wombat cubes are nature's strangest geometry flex.", symbolName: "cube.fill", paletteIndex: 2),
        FunFact(text: "The first computer bug was an actual moth.", symbolName: "cpu.fill", paletteIndex: 3),
        FunFact(text: "There are more possible chess games than atoms in Earth.", symbolName: "checkerboard.rectangle", paletteIndex: 4),
        FunFact(text: "Your bones are about five times stronger than steel by weight.", symbolName: "figure.walk", paletteIndex: 5),
        FunFact(text: "A teaspoon of neutron star matter would weigh billions of tons.", symbolName: "atom", paletteIndex: 0),
        FunFact(text: "The Moon is slowly drifting away from Earth.", symbolName: "circle.lefthalf.filled", paletteIndex: 1),
        FunFact(text: "Some metals explode when they touch water.", symbolName: "bolt.fill", paletteIndex: 2),
        FunFact(text: "The shortest war in history lasted under an hour.", symbolName: "timer", paletteIndex: 3),
        FunFact(text: "A group of flamingos is called a flamboyance.", symbolName: "paintpalette.fill", paletteIndex: 4),
        FunFact(text: "The human nose can remember around 50,000 scents.", symbolName: "wind", paletteIndex: 5),
        FunFact(text: "Saturn would float in water if you had a big enough bathtub.", symbolName: "circle.grid.cross.fill", paletteIndex: 0),
        FunFact(text: "The dot over a lowercase i is called a tittle.", symbolName: "textformat", paletteIndex: 1),
        FunFact(text: "Some turtles can breathe through their back end.", symbolName: "bubble.left.and.bubble.right.fill", paletteIndex: 2),
        FunFact(text: "The first oranges were probably green.", symbolName: "circle.fill", paletteIndex: 3),
        FunFact(text: "A bolt of lightning is hotter than the Sun's surface.", symbolName: "cloud.bolt.fill", paletteIndex: 4),
        FunFact(text: "Most of the oxygen you breathe comes from ocean plankton.", symbolName: "water.waves", paletteIndex: 5),
        FunFact(text: "The word laser began as an acronym.", symbolName: "laser.burst", paletteIndex: 0),
        FunFact(text: "Some diamonds rain down inside Neptune and Uranus.", symbolName: "diamond.fill", paletteIndex: 1),
        FunFact(text: "Your brain uses about 20 percent of your body's energy.", symbolName: "brain.head.profile", paletteIndex: 2),
        FunFact(text: "The first alarm clock could ring only at 4 a.m.", symbolName: "alarm.fill", paletteIndex: 3),
        FunFact(text: "Hot water can freeze faster than cold water in some conditions.", symbolName: "snowflake", paletteIndex: 4),
        FunFact(text: "A single strand of spider silk can be tougher than steel.", symbolName: "line.diagonal", paletteIndex: 5),
        FunFact(text: "The Pacific Ocean is wider than the Moon.", symbolName: "globe.americas.fill", paletteIndex: 0),
        FunFact(text: "Some sea slugs can photosynthesize after eating algae.", symbolName: "sun.max.fill", paletteIndex: 1),
        FunFact(text: "The inventor of the Frisbee was turned into one after death.", symbolName: "circle.dashed", paletteIndex: 2),
        FunFact(text: "The fingerprints of koalas are oddly human-like.", symbolName: "touchid", paletteIndex: 3),
        FunFact(text: "Sound travels about four times faster in water than in air.", symbolName: "speaker.wave.3.fill", paletteIndex: 4),
        FunFact(text: "A day on Mercury lasts about 59 Earth days.", symbolName: "smallcircle.filled.circle.fill", paletteIndex: 5),
        FunFact(text: "The smell after rain is called petrichor.", symbolName: "cloud.rain.fill", paletteIndex: 0),
        FunFact(text: "The longest hiccuping spell lasted for decades.", symbolName: "waveform.path.ecg", paletteIndex: 1),
        FunFact(text: "The first email was sent in 1971.", symbolName: "paperplane.fill", paletteIndex: 2),
        FunFact(text: "Gold is edible, but your lunch deserves better.", symbolName: "seal.fill", paletteIndex: 3),
        FunFact(text: "The Sun makes up more than 99 percent of the solar system's mass.", symbolName: "sun.max.circle.fill", paletteIndex: 4),
        FunFact(text: "A jiffy is a real unit of time in physics.", symbolName: "clock.badge.checkmark", paletteIndex: 5),
        FunFact(text: "The first webcam watched a coffee pot.", symbolName: "camera.fill", paletteIndex: 0),
        FunFact(text: "You can hear rhubarb grow in the right conditions.", symbolName: "ear.fill", paletteIndex: 1),
        FunFact(text: "The North Pole has no permanent time zone.", symbolName: "location.north.circle.fill", paletteIndex: 2),
        FunFact(text: "Glass is made mostly from sand.", symbolName: "hourglass", paletteIndex: 3),
        FunFact(text: "A hummingbird's heart can beat over 1,000 times per minute.", symbolName: "heart.fill", paletteIndex: 4),
        FunFact(text: "The universe has no known center.", symbolName: "scope", paletteIndex: 5)
    ]
}
