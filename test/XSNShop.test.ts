import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer, ContractFactory, Contract } from 'ethers';
import { XSNAKESToken } from '../typechain-types/Erc.sol/XSNAKESToken'; // импортируем типы для контракта токена

import XSNShopJSON from '../artifacts/contracts/Erc.sol/XSNShop.json';
import tokenJSON from '../artifacts/contracts/Erc.sol/XSNAKESToken.json';

describe("XSNShop", function () {
    let owner: Signer;
    let buyer: Signer;
    let shop: Contract; // типизируем контракт магазина
    let erc20: XSNAKESToken; // типизируем контракт токена

    beforeEach(async function () {
        [owner, buyer] = await ethers.getSigners();

        const XSNShopFactory: ContractFactory = await ethers.getContractFactory("XSNShop", owner);
        shop = await XSNShopFactory.deploy();
        await shop.deployed();

        erc20 = (await ethers.getContractAt(tokenJSON.abi, await shop.token(), owner)) as XSNAKESToken; // добавляем типизацию для контракта токена
    });

    it("Should have an owner and a token", async function () {
        expect(await shop.owner()).to.eq(await owner.getAddress()); // приводим адрес к строковому типу
        expect(await shop.token()).to.be.properAddress;
    })

    it("allows to buy", async function () {
        const tokenAmount = 3

        const txData = {
            value: tokenAmount,
            to: shop.address
        }

        const tx = await buyer.sendTransaction(txData)
        await tx.wait()

        expect(await erc20.balanceOf(await buyer.getAddress())).to.eq(tokenAmount)
        await expect(() => tx).
            to.changeEtherBalance(shop, tokenAmount)

        await expect(tx).
            to.emit(shop, "Bought")
            .withArgs(tokenAmount, await buyer.getAddress())
    })

    it("allows to sell", async function(){
        const tx = await buyer.sendTransaction({
            value: 3,
            to: shop.address
        })
        await tx.wait()

        const sellAmount = 2

        const approval = await erc20.connect(buyer).approw(shop.address, sellAmount)
        await approval.wait()

        const sellTx = await shop.connect(buyer).sell(sellAmount)

        expect(await erc20.balanceOf(await buyer.getAddress())).to.eq(1)

        await expect(()=> sellTx).
            to.changeEtherBalance(shop, -sellAmount)

        await expect(sellTx).
            to.emit(shop, "Sold")
            .withArgs(sellAmount, await buyer.getAddress()) 

    })


});