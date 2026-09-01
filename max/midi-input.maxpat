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
            900.0,
            780.0
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
        "description": "",
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
                        560.0,
                        20.0
                    ],
                    "fontsize": 13.0,
                    "text": "STAGE 1-2 \u2014 MIDI acquisition, and the OSC bridge to Python. Open the Max Console (Cmd-Shift-M) to see output."
                }
            },
            {
                "box": {
                    "id": "obj-c-live",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        30.0,
                        55.0,
                        250.0,
                        20.0
                    ],
                    "text": "SOURCE A \u2014 live kit, or IAC bus"
                }
            },
            {
                "box": {
                    "id": "obj-notein",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 3,
                    "outlettype": [
                        "int",
                        "int",
                        "int"
                    ],
                    "patching_rect": [
                        30.0,
                        80.0,
                        60.0,
                        22.0
                    ],
                    "text": "notein"
                }
            },
            {
                "box": {
                    "id": "obj-c-file",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        330.0,
                        55.0,
                        320.0,
                        20.0
                    ],
                    "text": "SOURCE B \u2014 file. Click read, pick scratch.mid, then start."
                }
            },
            {
                "box": {
                    "id": "obj-read",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [
                        ""
                    ],
                    "patching_rect": [
                        330.0,
                        80.0,
                        43.0,
                        22.0
                    ],
                    "text": "read"
                }
            },
            {
                "box": {
                    "id": "obj-start",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [
                        ""
                    ],
                    "patching_rect": [
                        385.0,
                        80.0,
                        40.0,
                        22.0
                    ],
                    "text": "start"
                }
            },
            {
                "box": {
                    "id": "obj-stop",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [
                        ""
                    ],
                    "patching_rect": [
                        437.0,
                        80.0,
                        38.0,
                        22.0
                    ],
                    "text": "stop"
                }
            },
            {
                "box": {
                    "id": "obj-seq",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [
                        "int",
                        "bang"
                    ],
                    "patching_rect": [
                        330.0,
                        120.0,
                        40.0,
                        22.0
                    ],
                    "text": "seq"
                }
            },
            {
                "box": {
                    "id": "obj-midiparse",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 7,
                    "outlettype": [
                        "",
                        "",
                        "",
                        "int",
                        "int",
                        "int",
                        "int"
                    ],
                    "patching_rect": [
                        330.0,
                        155.0,
                        75.0,
                        22.0
                    ],
                    "text": "midiparse"
                }
            },
            {
                "box": {
                    "id": "obj-unpack",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [
                        "int",
                        "int"
                    ],
                    "patching_rect": [
                        330.0,
                        190.0,
                        75.0,
                        22.0
                    ],
                    "text": "unpack 0 0"
                }
            },
            {
                "box": {
                    "id": "obj-c-merge",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        130.0,
                        233.0,
                        330.0,
                        20.0
                    ],
                    "text": "both sources merge here \u2014 nothing below knows which fired"
                }
            },
            {
                "box": {
                    "id": "obj-stripnote",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 2,
                    "outlettype": [
                        "int",
                        "int"
                    ],
                    "patching_rect": [
                        30.0,
                        233.0,
                        72.0,
                        22.0
                    ],
                    "text": "stripnote"
                }
            },
            {
                "box": {
                    "id": "obj-loadbang",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [
                        "bang"
                    ],
                    "patching_rect": [
                        620.0,
                        180.0,
                        62.0,
                        22.0
                    ],
                    "text": "loadbang"
                }
            },
            {
                "box": {
                    "id": "obj-resetbtn",
                    "maxclass": "button",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [
                        "bang"
                    ],
                    "parameter_enable": 0,
                    "patching_rect": [
                        695.0,
                        180.0,
                        24.0,
                        24.0
                    ]
                }
            },
            {
                "box": {
                    "id": "obj-c-reset",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        725.0,
                        183.0,
                        120.0,
                        20.0
                    ],
                    "text": "reset clock"
                }
            },
            {
                "box": {
                    "id": "obj-timer",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [
                        "float"
                    ],
                    "patching_rect": [
                        620.0,
                        233.0,
                        45.0,
                        22.0
                    ],
                    "text": "timer"
                }
            },
            {
                "box": {
                    "id": "obj-trigger",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 3,
                    "outlettype": [
                        "int",
                        "int",
                        "bang"
                    ],
                    "patching_rect": [
                        30.0,
                        275.0,
                        55.0,
                        22.0
                    ],
                    "text": "t i i b"
                }
            },
            {
                "box": {
                    "id": "obj-div",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [
                        "float"
                    ],
                    "patching_rect": [
                        190.0,
                        275.0,
                        47.0,
                        22.0
                    ],
                    "text": "/ 127."
                }
            },
            {
                "box": {
                    "id": "obj-pack",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [
                        ""
                    ],
                    "patching_rect": [
                        380.0,
                        320.0,
                        65.0,
                        22.0
                    ],
                    "text": "pack 0 0"
                }
            },
            {
                "box": {
                    "id": "obj-printraw",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        380.0,
                        360.0,
                        65.0,
                        22.0
                    ],
                    "text": "print RAW"
                }
            },
            {
                "box": {
                    "id": "obj-c-raw",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        455.0,
                        360.0,
                        400.0,
                        20.0
                    ],
                    "text": "raw note + velocity \u2014 a pad missing from pad-map.txt shows up here only"
                }
            },
            {
                "box": {
                    "id": "obj-coll",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 4,
                    "outlettype": [
                        "",
                        "",
                        "",
                        "bang"
                    ],
                    "patching_rect": [
                        30.0,
                        330.0,
                        110.0,
                        22.0
                    ],
                    "text": "coll pad-map.txt"
                }
            },
            {
                "box": {
                    "id": "obj-c-coll",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        150.0,
                        333.0,
                        380.0,
                        20.0
                    ],
                    "text": "note number -> semantic name. Edit the text file, not the patch."
                }
            },
            {
                "box": {
                    "id": "obj-sprintf",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "outlettype": [
                        ""
                    ],
                    "patching_rect": [
                        30.0,
                        410.0,
                        245.0,
                        22.0
                    ],
                    "text": "sprintf %s vel %.3f t %.1f ms"
                }
            },
            {
                "box": {
                    "id": "obj-printhit",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        30.0,
                        450.0,
                        62.0,
                        22.0
                    ],
                    "text": "print HIT"
                }
            },
            {
                "box": {
                    "id": "obj-c-hit",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        105.0,
                        450.0,
                        460.0,
                        20.0
                    ],
                    "text": "named pad, velocity normalised 0.-1., ms since clock reset"
                }
            },
            {
                "box": {
                    "id": "obj-c-note",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "linecount": 3,
                    "patching_rect": [
                        30.0,
                        500.0,
                        800.0,
                        47.0
                    ],
                    "text": "Velocity is normalised here because the protocol downstream is semantic (design notes 4): names and 0.-1. floats, never note numbers. The note number and the 0-127 range die in this patch and nothing in Python ever learns they existed. Stage 1 exit condition: every pad and zone on the kit prints a stable, correctly named event."
                }
            },
            {
                "box": {
                    "id": "obj-bridge",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 0,
                    "patching_rect": [
                        30.0,
                        615.0,
                        100.0,
                        22.0
                    ],
                    "text": "python-bridge"
                }
            },
            {
                "box": {
                    "id": "obj-c-bridge",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        150.0,
                        600.0,
                        700.0,
                        47.0
                    ],
                    "text": "STAGE 2 \u2014 the same three values go to Python as OSC. Fed exactly like the sprintf above it, because it wants exactly the same things: name, velocity, milliseconds. Open python-bridge.maxpat (double-click it while the patch is unlocked) to see what it does."
                }
            }
        ],
        "lines": [
            {
                "patchline": {
                    "source": [
                        "obj-notein",
                        0
                    ],
                    "destination": [
                        "obj-stripnote",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-notein",
                        1
                    ],
                    "destination": [
                        "obj-stripnote",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-read",
                        0
                    ],
                    "destination": [
                        "obj-seq",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-start",
                        0
                    ],
                    "destination": [
                        "obj-seq",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-stop",
                        0
                    ],
                    "destination": [
                        "obj-seq",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-seq",
                        0
                    ],
                    "destination": [
                        "obj-midiparse",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-midiparse",
                        0
                    ],
                    "destination": [
                        "obj-unpack",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-unpack",
                        0
                    ],
                    "destination": [
                        "obj-stripnote",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-unpack",
                        1
                    ],
                    "destination": [
                        "obj-stripnote",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-loadbang",
                        0
                    ],
                    "destination": [
                        "obj-timer",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-resetbtn",
                        0
                    ],
                    "destination": [
                        "obj-timer",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-stripnote",
                        0
                    ],
                    "destination": [
                        "obj-trigger",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-stripnote",
                        1
                    ],
                    "destination": [
                        "obj-div",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-stripnote",
                        1
                    ],
                    "destination": [
                        "obj-pack",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-trigger",
                        2
                    ],
                    "destination": [
                        "obj-timer",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-trigger",
                        1
                    ],
                    "destination": [
                        "obj-pack",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-trigger",
                        0
                    ],
                    "destination": [
                        "obj-coll",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-timer",
                        0
                    ],
                    "destination": [
                        "obj-sprintf",
                        2
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-div",
                        0
                    ],
                    "destination": [
                        "obj-sprintf",
                        1
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-coll",
                        0
                    ],
                    "destination": [
                        "obj-sprintf",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-sprintf",
                        0
                    ],
                    "destination": [
                        "obj-printhit",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "source": [
                        "obj-pack",
                        0
                    ],
                    "destination": [
                        "obj-printraw",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "destination": [
                        "obj-bridge",
                        0
                    ],
                    "source": [
                        "obj-coll",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "destination": [
                        "obj-bridge",
                        1
                    ],
                    "source": [
                        "obj-div",
                        0
                    ]
                }
            },
            {
                "patchline": {
                    "destination": [
                        "obj-bridge",
                        2
                    ],
                    "source": [
                        "obj-timer",
                        0
                    ]
                }
            }
        ],
        "dependency_cache": [],
        "autosave": 0
    }
}
