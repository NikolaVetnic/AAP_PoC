{
    "patcher": {
        "fileversion": 1,
        "appversion": {
            "major": 8,
            "minor": 3,
            "revision": 3,
            "architecture": "x64",
            "modernui": 1
        },
        "classnamespace": "box",
        "rect": [
            60.0,
            100.0,
            860.0,
            540.0
        ],
        "bglocked": 0,
        "openinpresentation": 0,
        "default_fontsize": 12.0,
        "default_fontface": 0,
        "default_fontname": "Arial",
        "gridonopen": 1,
        "gridsize": [
            15.0,
            15.0
        ],
        "gridsnaponopen": 1,
        "objectsnaponopen": 1,
        "statusbarvisible": 2,
        "toolbarvisible": 1,
        "lefttoolbarpinned": 0,
        "toptoolbarpinned": 0,
        "righttoolbarpinned": 0,
        "bottomtoolbarpinned": 0,
        "toolbars_unpinned_last_save": 0,
        "tallnewobj": 0,
        "boxanimatetime": 200,
        "enablehscroll": 1,
        "enablevscroll": 1,
        "devicewidth": 0.0,
        "description": "Stage 2 OSC bridge: one hit -> one semantic OSC message to Python.",
        "digest": "",
        "tags": "",
        "style": "",
        "subpatcher_template": "",
        "assistshowspatchername": 0,
        "boxes": [
            {
                "box": {
                    "id": "obj-title",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        30.0,
                        15.0,
                        780.0,
                        20.0
                    ],
                    "text": "STAGE 2 \u2014 the OSC bridge. Every hit leaves Max here and arrives in Python as a semantic message (design notes 4, 36)."
                }
            },
            {
                "box": {
                    "id": "obj-c-abstraction",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        30.0,
                        45.0,
                        780.0,
                        33.0
                    ],
                    "text": "This file is an ABSTRACTION: it is meant to be used as an object called [python-bridge] inside another patch, not opened and played on its own. Opened alone, the three inlets below have nothing feeding them and nothing will happen."
                }
            },
            {
                "box": {
                    "id": "obj-in-pad",
                    "maxclass": "inlet",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "outlettype": [
                        ""
                    ],
                    "patching_rect": [
                        30.0,
                        105.0,
                        25.0,
                        25.0
                    ],
                    "comment": "pad name, symbol (HOT \u2014 this inlet triggers the send)"
                }
            },
            {
                "box": {
                    "id": "obj-in-vel",
                    "maxclass": "inlet",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "outlettype": [
                        ""
                    ],
                    "patching_rect": [
                        225.0,
                        105.0,
                        25.0,
                        25.0
                    ],
                    "comment": "velocity, float already normalised 0.-1."
                }
            },
            {
                "box": {
                    "id": "obj-in-ms",
                    "maxclass": "inlet",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "outlettype": [
                        ""
                    ],
                    "patching_rect": [
                        420.0,
                        105.0,
                        25.0,
                        25.0
                    ],
                    "comment": "milliseconds since the clock was reset, float"
                }
            },
            {
                "box": {
                    "id": "obj-c-inlets",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        30.0,
                        140.0,
                        780.0,
                        33.0
                    ],
                    "text": "The three inlets are the same three values, in the same order, that feed the [sprintf] in midi-input.maxpat. Wire this object exactly like that sprintf: coll -> left, / 127. -> middle, timer -> right."
                }
            },
            {
                "box": {
                    "id": "obj-sprintf",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "patching_rect": [
                        30.0,
                        195.0,
                        110.0,
                        22.0
                    ],
                    "text": "sprintf /hit/%s",
                    "outlettype": [
                        ""
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-c-sprintf",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        150.0,
                        198.0,
                        660.0,
                        33.0
                    ],
                    "text": "Builds the OSC address: snare becomes /hit/snare. The address carries the meaning, never a note number (4). The result contains no spaces, so sprintf emits it as one symbol \u2014 which is exactly what pack and udpsend need."
                }
            },
            {
                "box": {
                    "id": "obj-pack",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "patching_rect": [
                        30.0,
                        255.0,
                        90.0,
                        22.0
                    ],
                    "text": "pack s 0. 0.",
                    "outlettype": [
                        ""
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-c-pack",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        150.0,
                        258.0,
                        660.0,
                        33.0
                    ],
                    "text": "Assembles one message: the address symbol first, then the two floats. Max is right-to-left, so velocity and milliseconds are already sitting in the cold inlets by the time the pad name arrives at the hot one and pushes the message out."
                }
            },
            {
                "box": {
                    "id": "obj-udpsend",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        30.0,
                        315.0,
                        165.0,
                        22.0
                    ],
                    "text": "udpsend 127.0.0.1 7400"
                }
            },
            {
                "box": {
                    "id": "obj-c-udpsend",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        210.0,
                        318.0,
                        600.0,
                        47.0
                    ],
                    "text": "Out over the network as OSC. The port must match PORT_IN in src/aap/io/osc_input.py \u2014 7400. UDP is fire-and-forget: if Python is not listening, or is listening on another port, nothing is reported on this side. Silence in the Python console is the only symptom, which is why the port lives in exactly two places and both are written down."
                }
            },
            {
                "box": {
                    "id": "obj-print",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        30.0,
                        375.0,
                        105.0,
                        22.0
                    ],
                    "text": "print TO-PYTHON"
                }
            },
            {
                "box": {
                    "id": "obj-c-print",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        150.0,
                        378.0,
                        660.0,
                        33.0
                    ],
                    "text": "The same message, printed locally. Two consoles showing the same line is how you tell a Max problem from a Python problem: printed here but absent there means the packet is being lost between them."
                }
            },
            {
                "box": {
                    "id": "obj-c-note",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        30.0,
                        430.0,
                        780.0,
                        60.0
                    ],
                    "text": "Nothing is received back yet. Stage 3 adds the return path (a second port, 7500) and the immediate-sound optimisation: the struck note sounds in Max at once, and Python's answer arrives afterwards as elaboration (3.3). Python decides WHAT happens; Max decides HOW and exactly WHEN it sounds."
                }
            }
        ],
        "lines": [
            {
                "patchline": {
                    "destination": [
                        "obj-sprintf",
                        0
                    ],
                    "source": [
                        "obj-in-pad",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "destination": [
                        "obj-pack",
                        0
                    ],
                    "source": [
                        "obj-sprintf",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "destination": [
                        "obj-pack",
                        1
                    ],
                    "source": [
                        "obj-in-vel",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "destination": [
                        "obj-pack",
                        2
                    ],
                    "source": [
                        "obj-in-ms",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "destination": [
                        "obj-udpsend",
                        0
                    ],
                    "source": [
                        "obj-pack",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "destination": [
                        "obj-print",
                        0
                    ],
                    "source": [
                        "obj-pack",
                        0
                    ]
                }
            }
        ],
        "dependency_cache": [],
        "autosave": 0
    }
}
