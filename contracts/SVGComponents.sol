// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/SVG.sol";

contract SVGComponents {
    using Strings for uint256;

    function background() internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                SVG.tag(
                    abi.encodePacked("path"),
                    abi.encodePacked('fill="#22225E" d="M0 0h290v500H0z"'),
                    abi.encodePacked("")
                ),
                SVG.tag(
                    abi.encodePacked("path"),
                    abi.encodePacked('fill="#FFF" d="M270 1h19v498h-19z"'),
                    abi.encodePacked("")
                )
            );
    }

    function sideText(
        bytes memory _text,
        bytes memory _transform,
        bytes memory _style
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                SVG.tag(
                    abi.encodePacked("text"),
                    abi.encodePacked(
                        SVG.keyValue(
                            abi.encodePacked("class"),
                            abi.encodePacked("small")
                        ),
                        " ",
                        SVG.keyValue(abi.encodePacked("transform"), _transform),
                        " ",
                        SVG.keyValue(abi.encodePacked("style"), _style)
                    ),
                    _text
                )
            );
    }

    function titleStack(
        uint256 _x,
        uint256 _y,
        bytes memory _sub,
        bytes memory _title
    ) internal pure returns (bytes memory) {
        return
            SVG.tag(
                abi.encodePacked("text"),
                abi.encodePacked(
                    'class="title" transform=',
                    '"translate(',
                    _x.toString(),
                    ",",
                    _y.toString(),
                    ')"'
                ),
                abi.encodePacked(
                    SVG.tag(
                        abi.encodePacked("tspan"),
                        abi.encodePacked('class="small alpha" x="0"'),
                        _sub
                    ),
                    SVG.tag(
                        abi.encodePacked("tspan"),
                        abi.encodePacked('class="large" x="0" dy="20"'),
                        _title
                    )
                )
            );
    }
}
