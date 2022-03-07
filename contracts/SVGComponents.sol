// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "./libraries/SVG.sol";

contract SVGComponents {
    using Strings for uint256;

    function background() internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    SVG.tag("path", 'fill="#22225E" d="M0 0h290v500H0z"', ""),
                    SVG.tag("path", 'fill="#FFF" d="M270 1h19v498h-19z"', "")
                )
            );
    }

    function sideText(
        string memory _text,
        string memory _transform,
        string memory _style
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    SVG.tag(
                        "text",
                        string(
                            abi.encodePacked(
                                SVG.keyValue("class", "small"),
                                " ",
                                SVG.keyValue("transform", _transform),
                                " ",
                                SVG.keyValue("style", _style)
                            )
                        ),
                        _text
                    )
                )
            );
    }

    function titleStack(
        uint256 _x,
        uint256 _y,
        string memory _sub,
        string memory _title
    ) internal pure returns (string memory) {
        return
            SVG.tag(
                "text",
                string(
                    abi.encodePacked(
                        'class="title" transform=',
                        '"translate(',
                        _x.toString(),
                        ",",
                        _y.toString(),
                        ')"'
                    )
                ),
                string(
                    abi.encodePacked(
                        SVG.tag("tspan", 'class="small alpha" x="0"', _sub),
                        SVG.tag("tspan", 'class="large" x="0" dy="20"', _title)
                    )
                )
            );
    }
}
