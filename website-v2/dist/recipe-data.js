// Local recipe previews from supabase/content/livo_recipes.json.
// Ingredients and steps use the original recipe servings. Nutrition is per serving,
// calculated from ingredient amounts and the catalog values (including the base
// foods in supabase/migrations/0010_recipe_content.sql), rounded for display.
// Photos: see assets/ASSET_SOURCES.md. No API calls or account data.
window.LOOKIN_RECIPES = [
    {
        "id":  "livo-protein-oats",
        "title":  "Protein-Beeren-Oats",
        "image":  "assets/berry-oats.webp",
        "minutes":  8,
        "kcal":  362,
        "protein":  29.8,
        "carbs":  45.4,
        "fat":  4.3,
        "category":  "Frühstück",
        "premium":  false,
        "servings":  1,
        "ingredients":  [
                            {
                                "label":  "Haferflocken",
                                "amount":  "5 EL (50 g)"
                            },
                            {
                                "label":  "Skyr natur",
                                "amount":  "1 Becher (200 g)"
                            },
                            {
                                "label":  "Beeren-Mix",
                                "amount":  "1 Handvoll (100 g), frisch oder aufgetaut"
                            }
                        ],
        "steps":  [
                      "Die Haferflocken mit 4 EL Wasser in einer Schüssel verrühren und 3 Minuten quellen lassen.",
                      "Den Skyr dazugeben und alles glatt rühren, bis eine cremige Masse entsteht.",
                      "Die Beeren darauf verteilen und die Oats sofort servieren."
                  ],
        "description":  "Cremiges Frühstück aus Haferflocken, Skyr und Beeren – ganz ohne Kochen."
    },
    {
        "id":  "livo-salmon-avocado-rice",
        "title":  "Lachs-Avocado-Reis",
        "image":  "assets/salmon-bowl.webp",
        "minutes":  25,
        "kcal":  553,
        "protein":  30.3,
        "carbs":  43.6,
        "fat":  25.5,
        "category":  "Hauptgerichte",
        "premium":  true,
        "servings":  2,
        "ingredients":  [
                            {
                                "label":  "Lachsfilet",
                                "amount":  "2 Filets (250 g), mit oder ohne Haut"
                            },
                            {
                                "label":  "Reis, gekocht",
                                "amount":  "300 g, gekocht, z. B. vom Vortag"
                            },
                            {
                                "label":  "Avocado",
                                "amount":  "1 Avocado (120 g), in Scheiben"
                            },
                            {
                                "label":  "Zitronensaft",
                                "amount":  "2 TL (10 g)"
                            },
                            {
                                "label":  "Salz",
                                "amount":  "2 Prisen (2 g)"
                            },
                            {
                                "label":  "Pfeffer, schwarz",
                                "amount":  "1 Prise (0,5 g)"
                            }
                        ],
        "steps":  [
                      "Den gekochten Reis mit 2 EL Wasser in einem kleinen Topf mit Deckel bei niedriger Hitze etwa 5 Minuten erwärmen.",
                      "Den Lachs trocken tupfen und von beiden Seiten mit Salz und Pfeffer würzen.",
                      "Die Pfanne ohne Öl bei mittlerer Hitze erwärmen. Den Lachs mit der Hautseite nach unten 5 Minuten braten, wenden und weitere 3 Minuten garen, bis er innen nicht mehr glasig ist.",
                      "Die Avocado halbieren, entkernen, in Scheiben schneiden und mit etwas Zitronensaft beträufeln.",
                      "Reis auf zwei Teller verteilen, Lachs und Avocado darauf legen und mit restlichem Zitronensaft servieren."
                  ],
        "description":  "Gebratener Lachs auf Reis mit Avocado und einem Spritzer Zitrone."
    },
    {
        "id":  "livo-skyr-berry-bowl",
        "title":  "Skyr-Beeren-Bowl",
        "image":  "assets/skyr-bowl.webp",
        "minutes":  5,
        "kcal":  233,
        "protein":  28.7,
        "carbs":  23.7,
        "fat":  1,
        "category":  "Frühstück",
        "premium":  false,
        "servings":  1,
        "ingredients":  [
                            {
                                "label":  "Skyr natur",
                                "amount":  "1 Becher (250 g)"
                            },
                            {
                                "label":  "Beeren-Mix",
                                "amount":  "1 Handvoll (120 g), frisch oder aufgetaut"
                            },
                            {
                                "label":  "Honig",
                                "amount":  "1 TL (5 g)"
                            }
                        ],
        "steps":  [
                      "Den Skyr in eine Schüssel geben und kurz glatt rühren, damit er cremiger wird.",
                      "Die Beeren darauf verteilen, gefrorene Beeren vorher auftauen lassen.",
                      "Den Honig darüberträufeln und die Bowl direkt servieren."
                  ],
        "description":  "Schneller Snack aus Skyr, Beeren und einem Hauch Honig."
    },
    {
        "id":  "livo-apfel-zimt-porridge",
        "title":  "Apfel-Zimt-Porridge",
        "image":  "assets/apple-oats.webp",
        "minutes":  12,
        "kcal":  419,
        "protein":  15.0,
        "carbs":  62.8,
        "fat":  11.8,
        "category":  "Frühstück",
        "premium":  false,
        "servings":  1,
        "ingredients":  [
                            {
                                "label":  "Haferflocken",
                                "amount":  "5 EL (50 g)"
                            },
                            {
                                "label":  "Milch",
                                "amount":  "250 ml (250 g)"
                            },
                            {
                                "label":  "Apfel",
                                "amount":  "1 Apfel (120 g), gewürfelt"
                            },
                            {
                                "label":  "Zimt, gemahlen",
                                "amount":  "½ TL (1 g)"
                            },
                            {
                                "label":  "Honig",
                                "amount":  "1 TL (5 g)"
                            },
                            {
                                "label":  "Salz",
                                "amount":  "1 Prise (0,5 g)"
                            }
                        ],
        "steps":  [
                      "Haferflocken, Milch und Salz in einem Topf aufkochen und bei niedriger Hitze unter Rühren 5 Minuten köcheln lassen.",
                      "Den Apfel würfeln und in einer kleinen Pfanne mit 2 EL Wasser, Honig und Zimt 4 Minuten weich dünsten.",
                      "Das Porridge in eine Schale füllen und die warmen Zimtäpfel darauf verteilen."
                  ],
        "description":  "Warmer Haferbrei mit Milch, gebratenen Apfelwürfeln und Zimt – aus fünf Vorratszutaten."
    },
    {
        "id":  "livo-rote-linsen-dal",
        "title":  "Rote-Linsen-Dal mit Reis",
        "image":  "assets/lentil-dal.webp",
        "minutes":  35,
        "kcal":  544,
        "protein":  21.5,
        "carbs":  99.3,
        "fat":  7.6,
        "category":  "Hauptgerichte",
        "premium":  false,
        "servings":  4,
        "ingredients":  [
                            {
                                "label":  "Rote Linsen, getrocknet",
                                "amount":  "250 g (250 g)"
                            },
                            {
                                "label":  "Reis, ungekocht",
                                "amount":  "250 g (250 g)"
                            },
                            {
                                "label":  "Dosentomaten, gehackt",
                                "amount":  "1 Dose (400 g)"
                            },
                            {
                                "label":  "Zwiebeln",
                                "amount":  "1 Zwiebel (100 g), fein gewürfelt"
                            },
                            {
                                "label":  "Knoblauch",
                                "amount":  "3 Zehen (9 g), gehackt"
                            },
                            {
                                "label":  "Rapsöl",
                                "amount":  "2 EL (20 g)"
                            },
                            {
                                "label":  "Currypulver",
                                "amount":  "1 EL (8 g)"
                            },
                            {
                                "label":  "Kreuzkümmel, gemahlen",
                                "amount":  "1 TL (3 g)"
                            },
                            {
                                "label":  "Gemüsebrühe, zubereitet",
                                "amount":  "700 ml (700 g)"
                            },
                            {
                                "label":  "Zitronensaft",
                                "amount":  "1 EL (15 g)"
                            },
                            {
                                "label":  "Salz",
                                "amount":  "½ TL (3 g)"
                            }
                        ],
        "steps":  [
                      "Die Linsen in einem Sieb unter kaltem Wasser spülen, bis das Wasser klar abläuft.",
                      "Den Reis mit 500 ml Wasser und einer Prise Salz aufkochen und zugedeckt bei niedriger Hitze 15 Minuten garen. Danach 5 Minuten ruhen lassen.",
                      "Das Öl im großen Topf erhitzen. Zwiebel 3 Minuten glasig dünsten, dann Knoblauch, Curry und Kreuzkümmel 1 Minute mitrösten.",
                      "Linsen, Dosentomaten und Brühe zugeben, aufkochen und 15 bis 18 Minuten offen köcheln lassen, bis die Linsen zerfallen. Gelegentlich umrühren.",
                      "Mit Zitronensaft und Salz abschmecken und das Dal mit dem Reis servieren."
                  ],
        "description":  "Cremiges Linsencurry aus roten Linsen und Dosentomaten, dazu Reis – vegan, günstig und sättigend."
    },
    {
        "id":  "livo-nudeln-tomatensauce",
        "title":  "Nudeln mit Tomatensauce",
        "image":  "assets/tomato-pasta.webp",
        "minutes":  25,
        "kcal":  591,
        "protein":  18.9,
        "carbs":  106.9,
        "fat":  10.0,
        "category":  "Hauptgerichte",
        "premium":  false,
        "servings":  2,
        "ingredients":  [
                            {
                                "label":  "Nudeln, ungekocht",
                                "amount":  "250 g (250 g)"
                            },
                            {
                                "label":  "Dosentomaten, gehackt",
                                "amount":  "1 Dose (400 g)"
                            },
                            {
                                "label":  "Tomatenmark",
                                "amount":  "1 EL (15 g)"
                            },
                            {
                                "label":  "Zwiebeln",
                                "amount":  "1 Zwiebel (80 g), fein gewürfelt"
                            },
                            {
                                "label":  "Knoblauch",
                                "amount":  "2 Zehen (6 g), gehackt"
                            },
                            {
                                "label":  "Olivenöl",
                                "amount":  "1½ EL (15 g)"
                            },
                            {
                                "label":  "Oregano, getrocknet",
                                "amount":  "½ TL (1 g)"
                            },
                            {
                                "label":  "Salz",
                                "amount":  "1 TL (5 g), für Nudelwasser und Sauce"
                            },
                            {
                                "label":  "Pfeffer, schwarz",
                                "amount":  "1 Prise (0,5 g)"
                            }
                        ],
        "steps":  [
                      "Reichlich Wasser im großen Topf aufkochen und leicht salzen.",
                      "Das Öl im zweiten Topf erhitzen, die Zwiebel 3 Minuten glasig dünsten, dann Knoblauch und Tomatenmark 1 Minute mitrösten.",
                      "Dosentomaten und Oregano zugeben und die Sauce 10 Minuten offen köcheln lassen. Mit Salz und Pfeffer abschmecken.",
                      "Währenddessen die Nudeln nach Packungsangabe bissfest kochen. Vor dem Abgießen eine Tasse Nudelwasser abnehmen.",
                      "Die Nudeln abgießen, mit der Sauce vermengen und bei Bedarf mit etwas Nudelwasser cremiger machen."
                  ],
        "description":  "Schnelle Tomatensauce aus der Dose mit Zwiebel, Knoblauch und Oregano – der Vorrats-Klassiker."
    }
];
