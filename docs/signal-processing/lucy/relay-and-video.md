# Fleet relay and dispatch video

A future staged trial may assign two UAVs adjacent approved observation areas and use an overlapping checkpoint. Use a pilot for each aircraft and have dispatch compare both feeds. Switch the primary view when the second stream is fresh and shows the consenting courier or staged exchange. If neither view is usable, show a coverage gap. Pilot authority, flight limits, and recovery procedures apply to each aircraft throughout.

| Layer | Function |
| --- | --- |
| Route plan | Defines where an aircraft may fly. A paired beacon can cue framing within that area. A courier deviation does not revise the flight plan. |
| Observation handoff | Changes which feed dispatch monitors. Check frame age and whether the exchange is actually visible. |
| Radio mesh | Provides a possible data path via an intermediate node. Trial independent links first to establish whether the extra hop is useful. |
| Ground backhaul | Connects a controller or dock to dispatch. A ground-based Starlink terminal is a candidate where it has a clear sky view. The aircraft still needs its own control and video link to the ground. |
| Dispatch dashboard | FlytBase Video Wall and DJI FlightHub 2 document multiple live feeds on compatible systems. Neither can recover an obscured camera view. |

An aircraft feed can stay fresh while a wall or vehicle blocks the view of the courier. A wearable feed can show the courier's surroundings during that gap. Label which source is live and distinguish stale video from a fresh stream with an unusable view. For Canadian aviation purposes, visual line of sight concerns direct sight of the aircraft by the pilot or a visual observer under applicable rules. Transport Canada lists flying more than one aircraft BVLOS as a special operation. See the [weight and airspace matrix](uav-observation.md#canadian-requirements-for-the-proposed-flight).

Measure seconds without a usable view during the changeover, age of the last frame, and time to restore a usable view. Repeat with a missing second feed and with ground backhaul disconnected. Preserve the receipt-based custody workflow through all tests.

[FlytBase Video Wall](https://docs.flytbase.com/in-flight-modules/video-wall) · [DJI FlightHub 2](https://enterprise.dji.com/flighthub-2) · [Starlink Mini](https://starlink.com/gd/mini-product-us) · [Transport Canada special operations](https://tc.canada.ca/en/aviation/drone-safety/drone-pilot-licensing/get-permission-special-drone-operations)
