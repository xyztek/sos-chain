import { expect } from "chai";
import { ContractReceipt, Event } from "ethers";
import { ethers } from "hardhat";

describe("SOS", function () {
  before(async function () {
    this.factory = await ethers.getContractFactory("SOS");

    this.registryFactory = await ethers.getContractFactory(
      "contracts/Registry.sol:Registry"
    );

    this.registry = await this.registryFactory.deploy();

    this.fundManagerFactory = await ethers.getContractFactory(
      "contracts/FundManager.sol:FundManager"
    );

    this.fundManager = await this.fundManagerFactory.deploy();

    await this.registry.register("FUND_MANAGER", this.fundManager.address);

    await this.fundManager.setupFund(
      "UNICEF_011",
      "UNICEF Test Fund",
      "Test",
      ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"],
      "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
    );

    this.svgFactory = await ethers.getContractFactory("SVG");

    this.svg = await this.svgFactory.deploy();

    this.descriptorFactory = await ethers.getContractFactory("NFTDescriptor", {
      libraries: { SVG: this.svg.address },
    });

    this.descriptor = await this.descriptorFactory.deploy();

    await this.registry.register("NFT_DESCRIPTOR", this.descriptor.address);
  });

  beforeEach(async function () {
    const [owner] = await ethers.getSigners();

    this.contract = await this.factory.deploy(
      this.registry.address,
      owner.address
    );

    await this.contract.deployed();
  });

  it("should mint an ERC721", async function () {
    await expect(
      this.contract.mint(
        "0xEcdA812a67Ff9EB0257732D6a361008864275fCC",
        "UNICEF_011",
        ethers.constants.WeiPerEther.mul(1000),
        "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
      )
    ).to.emit(this.contract, "Transfer");
  });

  it("should return a token URI for an ERC721", async function () {
    const tx = await this.contract.mint(
      "0xEcdA812a67Ff9EB0257732D6a361008864275fCC",
      "UNICEF_011",
      ethers.constants.WeiPerEther.mul(1000),
      "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
    );

    const receipt: ContractReceipt = await tx.wait();
    const event = receipt.events?.filter(
      (x: Event) => x.event == "Transfer"
    )[0];

    const tokenURI = await this.contract.tokenURI(event?.args?.tokenId!);

    expect(tokenURI).to.eq(
      "PHN2ZyB3aWR0aD0iMjkwIiBoZWlnaHQ9IjUwMCIgdmlld0JveD0iMCAwIDI5MCA1MDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHN0eWxlPjwhW0NEQVRBW3RleHR7Zm9udC1mYW1pbHk6SGVsdmV0aWNhO2ZvbnQtd2VpZ2h0OjEwMH0uYWxwaGF7b3BhY2l0eTowLjV9LnNtYWxse2ZvbnQtc2l6ZTouOHJlbX0ubGFyZ2V7Zm9udC1zaXplOjEuMnJlbX0udGl0bGV7ZmlsbDojZmZmfV1dPjwvc3R5bGU+PHBhdGggZmlsbD0iIzIyMjI1RSIgZD0iTTAgMGgyOTB2NTAwSDB6Ij48L3BhdGg+PHBhdGggZmlsbD0iI0ZGRiIgZD0iTTI3MCAxaDE5djQ5OGgtMTl6Ij48L3BhdGg+PGcgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTYgMTYpIj48cGF0aCBkPSJtNTIuNyAyNy41IDMuNi0yLjFjLjggMi4yIDIuNCAzLjMgNC45IDMuMyAyLjQgMCAzLjQtLjkgMy40LTIuMyAwLS43LS40LTEuNC0xLTEuNy0uNy0uNC0xLjktLjktMy42LTEuNC0xLjktLjYtMy4xLTEtNC40LTItMS4zLS45LTItMi40LTItNC40cy43LTMuNSAyLTQuNmMxLjQtMS4xIDMuMi0xLjggNS0xLjcgMy40IDAgNi4xIDEuOCA3LjYgNC44bC0zLjUgMmMtLjktMS44LTIuMi0yLjctNC4xLTIuNy0xLjcgMC0yLjguOS0yLjggMi4xIDAgLjcuMyAxLjMuOCAxLjYuNi40IDEuNi45IDMuMiAxLjNsMS41LjVjLjUuMi45LjMgMS40LjVzLjkuNCAxLjMuN2MuNy40IDEuNiAxLjEgMiAxLjkuNS45LjggMiAuOCAzIDAgMi0uNyAzLjUtMi4yIDQuNy0xLjQgMS4xLTMuMyAxLjctNS42IDEuNy00LjIgMC03LjEtMi04LjMtNS4yem0yOCA1LjJjLTYgLjEtMTEtNC43LTExLjEtMTAuOHYtLjNjLS4xLTIuOSAxLjEtNS44IDMuMi03LjggNC4zLTQuMyAxMS4zLTQuMyAxNS43IDAgMi4xIDIgMy4zIDQuOSAzLjIgNy44LjEgNi00LjggMTEtMTAuOCAxMS4xLS4xLjEtLjEuMS0uMiAwem0wLTQuMWMxLjguMSAzLjYtLjcgNC45LTJzMi0zLjEgMi01Yy4xLTEuOS0uNy0zLjctMi01LTIuNy0yLjYtNy4xLTIuNi05LjggMC0xLjMgMS4zLTIgMy4xLTIgNS0uMSAxLjkuNyAzLjcgMiA1IDEuMyAxLjQgMyAyLjEgNC45IDJ6bTExLjQtMS4xIDMuNi0yLjFjLjggMi4yIDIuNSAzLjMgNC45IDMuM3MzLjQtLjkgMy40LTIuM2MwLS43LS40LTEuNC0xLTEuNy0uNy0uNC0xLjktLjktMy42LTEuNC0xLjktLjYtMy4xLTEtNC40LTItMS4zLS45LTItMi40LTItNC40cy43LTMuNSAyLTQuNmMxLjQtMS4xIDMuMi0xLjggNS0xLjcgMy40IDAgNi4xIDEuOCA3LjYgNC44bC0zLjUgMmMtLjktMS44LTIuMi0yLjctNC4xLTIuNy0xLjcgMC0yLjguOS0yLjggMi4xIDAgLjcuMyAxLjMuOCAxLjYuNi40IDEuNi45IDMuMiAxLjNsMS41LjVjLjUuMi45LjMgMS40LjVzLjkuNCAxLjMuN2MuNy40IDEuNiAxLjEgMiAxLjkuNS45LjggMiAuOCAzIDAgMi0uNyAzLjUtMi4yIDQuN3MtMy4zIDEuNy01LjYgMS43Yy00LjIgMC03LjEtMi04LjMtNS4yem0yNy41IDJjLTIuMS0yLjEtMy4yLTQuOS0zLjEtNy44IDAtMy4xIDEtNS43IDMuMS03LjhzNC43LTMuMiA3LjktMy4yYzEuOSAwIDMuNy41IDUuNCAxLjQgMS42LjkgMi45IDIuMiAzLjggMy43bC0xLjQuOGMtLjctMS4zLTEuOC0yLjQtMy4xLTMuMi0xLjQtLjgtMy0xLjItNC42LTEuMi0yLjggMC01IC45LTYuOCAyLjdzLTIuNyA0LjItMi42IDYuN2MtLjEgMi41LjkgNC45IDIuNiA2LjcgMS44IDEuOCA0LjEgMi43IDYuOCAyLjcgMy4zIDAgNi4zLTEuOCA3LjctNC41bDEuNC44Yy0xLjcgMy4yLTUuMyA1LjItOS4yIDUuMi0zLjIuMi01LjgtLjktNy45LTN6TTE1My43IDExaDEuNnYyMS4zaC0xLjZWMjIuMWgtMTIuNHYxMC4yaC0xLjZWMTFoMS42djkuNmgxMi40VjExem0yMC41IDIxLjMtMi4xLTUuNGgtMTAuN2wtMi4xIDUuNGgtMS43bDguMy0yMS4zaDEuN2w4LjIgMjEuM2gtMS42em0tMTIuMS02LjloOS41TDE2Ni44IDEzbC00LjcgMTIuNHpNMTc4LjMgMTFoMS42djIxLjNoLTEuNlYxMXptMjAuMSAwaDEuNnYyMS4zaC0xLjRMMTg2IDE0djE4LjNoLTEuNlYxMWgxLjRsMTIuNiAxOC4zVjExeiIgc3R5bGU9ImZpbGw6I2ZmZiIvPjxsaW5lYXJHcmFkaWVudCBpZD0iU1ZHSURfMV8iIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIiB4MT0iNTcuOTEzIiB5MT0iMTc5LjI3MiIgeDI9Ijk4LjY1NSIgeTI9IjIyMC4wMjQiIGdyYWRpZW50VHJhbnNmb3JtPSJ0cmFuc2xhdGUoMCAtNTUuNzYpIHNjYWxlKC4zMDk3KSI+PHN0b3Agb2Zmc2V0PSIwIiBzdHlsZT0ic3RvcC1jb2xvcjojMzY1ZmM4Ii8+PHN0b3Agb2Zmc2V0PSIuMDUiIHN0eWxlPSJzdG9wLWNvbG9yOiMzMzY4Y2EiLz48c3RvcCBvZmZzZXQ9Ii4zNyIgc3R5bGU9InN0b3AtY29sb3I6IzIyOWVkNCIvPjxzdG9wIG9mZnNldD0iLjY1IiBzdHlsZT0ic3RvcC1jb2xvcjojMTVjNmRjIi8+PHN0b3Agb2Zmc2V0PSIuODciIHN0eWxlPSJzdG9wLWNvbG9yOiMwZGRlZTAiLz48c3RvcCBvZmZzZXQ9IjEiIHN0eWxlPSJzdG9wLWNvbG9yOiMwYWU3ZTIiLz48L2xpbmVhckdyYWRpZW50PjxwYXRoIGQ9Im0xNCAzLjcgNi4yIDYuMmMuOS0uOSAyLjQtLjkgMy4zIDBzLjkgMi40IDAgMy4zYzIuNS0yLjQgNS45LTMuNiA5LjQtMy4yQzMyLjEgNCAyNi40LS4zIDIwLjQuNSAxOCAuOCAxNS43IDEuOSAxNCAzLjd6IiBzdHlsZT0iZmlsbDp1cmwoI1NWR0lEXzFfKSIvPjxsaW5lYXJHcmFkaWVudCBpZD0iU1ZHSURfMl8iIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIiB4MT0iNzkuNzM2IiB5MT0iMzIwLjczIiB4Mj0iMzguOTg1IiB5Mj0iMjc5Ljk3OSIgZ3JhZGllbnRUcmFuc2Zvcm09InRyYW5zbGF0ZSgwIC01NS43Nikgc2NhbGUoLjMwOTcpIj48c3RvcCBvZmZzZXQ9IjAiIHN0eWxlPSJzdG9wLWNvbG9yOiMzNjVmYzgiLz48c3RvcCBvZmZzZXQ9Ii4wNSIgc3R5bGU9InN0b3AtY29sb3I6IzMzNjhjYSIvPjxzdG9wIG9mZnNldD0iLjM3IiBzdHlsZT0ic3RvcC1jb2xvcjojMjI5ZWQ0Ii8+PHN0b3Agb2Zmc2V0PSIuNjUiIHN0eWxlPSJzdG9wLWNvbG9yOiMxNWM2ZGMiLz48c3RvcCBvZmZzZXQ9Ii44NyIgc3R5bGU9InN0b3AtY29sb3I6IzBkZGVlMCIvPjxzdG9wIG9mZnNldD0iMSIgc3R5bGU9InN0b3AtY29sb3I6IzBhZTdlMiIvPjwvbGluZWFyR3JhZGllbnQ+PHBhdGggZD0iTTE5LjEgMzMuNGMtLjktLjktLjktMi41IDAtMy40LTIuNCAyLjQtNS45IDMuNy05LjQgMy4zLjggNi4xIDYuNCAxMC4zIDEyLjUgOS41IDIuNC0uMyA0LjYtMS40IDYuMy0zLjJsLTYuMi02LjJjLS45LjktMi4zLjktMy4yIDB6IiBzdHlsZT0iZmlsbDp1cmwoI1NWR0lEXzJfKSIvPjxsaW5lYXJHcmFkaWVudCBpZD0iU1ZHSURfM18iIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIiB4MT0iMjcuODQxIiB5MT0iMjA5LjE4MSIgeDI9IjEwOS4zOTEiIHkyPSIyOTAuNzMxIiBncmFkaWVudFRyYW5zZm9ybT0idHJhbnNsYXRlKDAgLTU1Ljc2KSBzY2FsZSguMzA5NykiPjxzdG9wIG9mZnNldD0iMCIgc3R5bGU9InN0b3AtY29sb3I6I2RlMDE2YSIvPjxzdG9wIG9mZnNldD0iLjE4IiBzdHlsZT0ic3RvcC1jb2xvcjojZDgwMTZhIi8+PHN0b3Agb2Zmc2V0PSIuNDEiIHN0eWxlPSJzdG9wLWNvbG9yOiNjODAyNmEiLz48c3RvcCBvZmZzZXQ9Ii42NiIgc3R5bGU9InN0b3AtY29sb3I6I2FkMDQ2OSIvPjxzdG9wIG9mZnNldD0iLjk0IiBzdHlsZT0ic3RvcC1jb2xvcjojODcwNjY4Ii8+PHN0b3Agb2Zmc2V0PSIxIiBzdHlsZT0ic3RvcC1jb2xvcjojN2YwNzY4Ii8+PC9saW5lYXJHcmFkaWVudD48cGF0aCBkPSJNMzkuMiAxMy4yYy0xLjctMS43LTMuOS0yLjgtNi4zLTMuMi0zLjQtLjUtNi45LjctOS40IDMuMkwxMi44IDIzLjljLS45LjktMi40LjgtMy4zLS4xLS44LS45LS44LTIuMyAwLTMuMkwyMC4yIDkuOSAxNCAzLjcgMy4zIDE0LjRDLTEgMTguNy0xIDI1LjggMy4zIDMwLjFjMS43IDEuNyA0IDIuOCA2LjMgMy4yIDMuNC41IDYuOS0uNyA5LjQtMy4ybDEwLjctMTAuNy4yLS4yYzEtLjggMi41LS42IDMuMy40LjcuOS43IDIuMi0uMiAzLjFMMjIuMyAzMy40bDYuMiA2LjIgMTAuNy0xMC43YzQuNC00LjMgNC40LTExLjMgMC0xNS43eiIgc3R5bGU9ImZpbGw6dXJsKCNTVkdJRF8zXykiLz48L2c+PHRleHQgY2xhc3M9InNtYWxsIiB0cmFuc2Zvcm09InJvdGF0ZSg5MCAxMzIuNSAxNDIuNSkiIHN0eWxlPSJ0ZXh0LWFuY2hvcjpzdGFydCI+MTwvdGV4dD48dGV4dCBjbGFzcz0ic21hbGwiIHRyYW5zZm9ybT0icm90YXRlKDkwIC0xMDcuNSAzODIuNSkiIHN0eWxlPSJ0ZXh0LWFuY2hvcjplbmQiPjB4YTBiODY5OTFjNjIxOGIzNmMxZDE5ZDRhMmU5ZWIwY2UzNjA2ZWI0ODwvdGV4dD48dGV4dCBjbGFzcz0idGl0bGUiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDIwLDEwMCkiPjx0c3BhbiBjbGFzcz0ic21hbGwgYWxwaGEiIHg9IjAiPkZ1bmQ8L3RzcGFuPjx0c3BhbiBjbGFzcz0ibGFyZ2UiIHg9IjAiIGR5PSIyMCI+VU5JQ0VGIFRlc3QgRnVuZDwvdHNwYW4+PC90ZXh0Pjx0ZXh0IGNsYXNzPSJ0aXRsZSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMjAsMTUwKSI+PHRzcGFuIGNsYXNzPSJzbWFsbCBhbHBoYSIgeD0iMCI+Rm9jdXM8L3RzcGFuPjx0c3BhbiBjbGFzcz0ibGFyZ2UiIHg9IjAiIGR5PSIyMCI+VGVzdDwvdHNwYW4+PC90ZXh0Pjx0ZXh0IGNsYXNzPSJ0aXRsZSIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMjAsMjAwKSI+PHRzcGFuIGNsYXNzPSJzbWFsbCBhbHBoYSIgeD0iMCI+U3VwcG9ydDwvdHNwYW4+PHRzcGFuIGNsYXNzPSJsYXJnZSIgeD0iMCIgZHk9IjIwIj4xMDAwPC90c3Bhbj48L3RleHQ+PHJlY3QgeD0iMjM1IiB5PSI0ODAiIHdpZHRoPSIxMCIgaGVpZ2h0PSIxMCIgZmlsbD0iIzA2ZWI0OCI+PC9yZWN0PjxyZWN0IHg9IjI1MCIgeT0iNDgwIiB3aWR0aD0iMTAiIGhlaWdodD0iMTAiIGZpbGw9IiNhMGI4NjkiPjwvcmVjdD48L3N2Zz4="
    );
  });
});
