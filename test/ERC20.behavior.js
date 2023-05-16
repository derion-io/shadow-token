const { BN, constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const { ZERO_ADDRESS, MAX_UINT256 } = constants;

function shouldBehaveLikeERC20(errorPrefix, initialSupply, initialHolder, recipient, anotherAccount) {
  describe('total supply', function () {
    it('returns the total amount of tokens', async function () {
      expect(await this.token.totalSupply()).to.be.bignumber.equal(initialSupply);
    });
  });

  describe('balanceOf', function () {
    describe('when the requested account has no tokens', function () {
      it('returns zero', async function () {
        expect(await this.token.balanceOf(anotherAccount)).to.be.bignumber.equal('0');
      });
    });

    describe('when the requested account has some tokens', function () {
      it('returns the total amount of tokens', async function () {
        expect(await this.token.balanceOf(initialHolder)).to.be.bignumber.equal(initialSupply);
      });
    });
  });

  describe('transfer', function () {
    shouldBehaveLikeERC20Transfer(errorPrefix, initialHolder, recipient, initialSupply, function (from, to, value) {
      return this.token.transfer(to, value, { from });
    });
  });

  describe('transfer from', function () {
    const spender = recipient;

    describe('when the token owner is not the zero address', function () {
      const tokenOwner = initialHolder;

      describe('when the recipient is not the zero address', function () {
        const to = anotherAccount;

        describe('when the spender has enough allowance', function () {
          beforeEach(async function () {
            await this.token.approve(spender, initialSupply, { from: initialHolder });
          });

          describe('when the token owner has enough balance', function () {
            const amount = initialSupply;

            it('transfers the requested amount', async function () {
              await this.token.transferFrom(tokenOwner, to, amount, { from: spender });

              expect(await this.token.balanceOf(tokenOwner)).to.be.bignumber.equal('0');

              expect(await this.token.balanceOf(to)).to.be.bignumber.equal(amount);
            });

            // it('decreases the spender allowance', async function () {
            //   await this.token.transferFrom(tokenOwner, to, amount, { from: spender });

            //   expect(await this.token.allowance(tokenOwner, spender)).to.be.bignumber.equal('0');
            // });

            it('emits a transfer event', async function () {
              expectEvent(await this.token.transferFrom(tokenOwner, to, amount, { from: spender }), 'Transfer', {
                from: tokenOwner,
                to: to,
                value: amount,
              });
            });

            // it('emits an approval event', async function () {
            //   expectEvent(await this.token.transferFrom(tokenOwner, to, amount, { from: spender }), 'Approval', {
            //     owner: tokenOwner,
            //     spender: spender,
            //     value: await this.token.allowance(tokenOwner, spender),
            //   });
            // });
          });

          describe('when the token owner does not have enough balance', function () {
            const amount = initialSupply;

            beforeEach('reducing balance', async function () {
              await this.token.transfer(to, 1, { from: tokenOwner });
            });

            it('reverts', async function () {
              await expectRevert(
                this.token.transferFrom(tokenOwner, to, amount, { from: spender }),
                `Timelock: insufficient balance for transfer`,
              );
            });
          });
        });

        describe('when the spender does not have enough allowance', function () {
          const allowance = initialSupply.subn(1);

          beforeEach(async function () {
            await this.token.approve(spender, allowance, { from: tokenOwner });
          });

          // describe('when the token owner has enough balance', function () {
          //   const amount = initialSupply;

          //   it('reverts', async function () {
          //     await expectRevert(
          //       this.token.transferFrom(tokenOwner, to, amount, { from: spender }),
          //       `${errorPrefix}: insufficient allowance`,
          //     );
          //   });
          // });

          describe('when the token owner does not have enough balance', function () {
            const amount = allowance;

            beforeEach('reducing balance', async function () {
              await this.token.transfer(to, 2, { from: tokenOwner });
            });

            it('reverts', async function () {
              await expectRevert(
                this.token.transferFrom(tokenOwner, to, amount, { from: spender }),
                `Timelock: insufficient balance for transfer`,
              );
            });
          });
        });

        describe('when the spender has unlimited allowance', function () {
          beforeEach(async function () {
            await this.token.approve(spender, MAX_UINT256, { from: initialHolder });
          });

          it('does not decrease the spender allowance', async function () {
            await this.token.transferFrom(tokenOwner, to, 1, { from: spender });

            expect(await this.token.allowance(tokenOwner, spender)).to.be.bignumber.equal(MAX_UINT256);
          });

          it('does not emit an approval event', async function () {
            expectEvent.notEmitted(await this.token.transferFrom(tokenOwner, to, 1, { from: spender }), 'Approval');
          });
        });
      });

      describe('when the recipient is the zero address', function () {
        const amount = initialSupply;
        const to = ZERO_ADDRESS;

        beforeEach(async function () {
          await this.token.approve(spender, amount, { from: tokenOwner });
        });

        it('reverts', async function () {
          await expectRevert(
            this.token.transferFrom(tokenOwner, to, amount, { from: spender }),
            `ERC1155: transfer to the zero address`,
          );
        });
      });
    });

    describe('when the token owner is the zero address', function () {
      const amount = 0;
      const tokenOwner = ZERO_ADDRESS;
      const to = recipient;

      it('reverts', async function () {
        await expectRevert(this.token.transferFrom(tokenOwner, to, amount, { from: spender }), 'ERC1155: caller is not token owner or approved');
      });
    });
  });

  describe('approve', function () {
    shouldBehaveLikeERC20Approve(
      errorPrefix,
      initialHolder,
      recipient,
      initialSupply,
      function (owner, spender, amount) {
        return this.token.approve(spender, amount, { from: owner });
      },
    );
  });
}

function shouldBehaveLikeERC20Transfer(errorPrefix, from, to, balance, transfer) {
  describe('when the recipient is not the zero address', function () {
    describe('when the sender does not have enough balance', function () {
      const amount = balance.addn(1);

      it('reverts', async function () {
        await expectRevert(transfer.call(this, from, to, amount), `Timelock: insufficient balance for transfer`);
      });
    });

    describe('when the sender transfers all balance', function () {
      const amount = balance;

      it('transfers the requested amount', async function () {
        await transfer.call(this, from, to, amount);

        expect(await this.token.balanceOf(from)).to.be.bignumber.equal('0');

        expect(await this.token.balanceOf(to)).to.be.bignumber.equal(amount);
      });

      it('emits a transfer event', async function () {
        expectEvent(await transfer.call(this, from, to, amount), 'Transfer', { from, to, value: amount });
      });
    });

    describe('when the sender transfers zero tokens', function () {
      const amount = new BN('0');

      it('transfers the requested amount', async function () {
        await transfer.call(this, from, to, amount);

        expect(await this.token.balanceOf(from)).to.be.bignumber.equal(balance);

        expect(await this.token.balanceOf(to)).to.be.bignumber.equal('0');
      });

      it('emits a transfer event', async function () {
        expectEvent(await transfer.call(this, from, to, amount), 'Transfer', { from, to, value: amount });
      });
    });
  });

  describe('when the recipient is the zero address', function () {
    it('reverts', async function () {
      await expectRevert(
        transfer.call(this, from, ZERO_ADDRESS, balance),
        `ERC1155: transfer to the zero address`,
      );
    });
  });
}

function shouldBehaveLikeERC20Approve(errorPrefix, owner, spender, supply, approve) {
  describe('when the spender is not the zero address', function () {
    describe('when the sender has enough balance', function () {
      const amount = supply;

      it('emits an approval event', async function () {
        // expectEvent(await approve.call(this, owner, spender, amount), 'Approval', {
        //   owner: owner,
        //   spender: spender,
        //   value: amount,
        // });
        expectEvent(await approve.call(this, owner, spender, amount), 'Approval', {
          owner: owner,
          spender: spender,
          value: '115792089237316195423570985008687907853269984665640564039457584007913129639935',
        });
      });

      describe('when there was no approved amount before', function () {
        it('approves the requested amount', async function () {
          await approve.call(this, owner, spender, amount);

          // expect(await this.token.allowance(owner, spender)).to.be.bignumber.equal(amount);
          expect(await this.token.allowance(owner, spender)).to.be.bignumber.equal('115792089237316195423570985008687907853269984665640564039457584007913129639935');
        });
      });

      describe('when the spender had an approved amount', function () {
        beforeEach(async function () {
          await approve.call(this, owner, spender, new BN(1));
        });

        it('approves the requested amount and replaces the previous one', async function () {
          await approve.call(this, owner, spender, amount);

          // expect(await this.token.allowance(owner, spender)).to.be.bignumber.equal(amount);
          expect(await this.token.allowance(owner, spender)).to.be.bignumber.equal('115792089237316195423570985008687907853269984665640564039457584007913129639935');
        });
      });
    });

    describe('when the sender does not have enough balance', function () {
      const amount = supply.addn(1);

      it('emits an approval event', async function () {
        // expectEvent(await approve.call(this, owner, spender, amount), 'Approval', {
        //   owner: owner,
        //   spender: spender,
        //   value: amount,
        // });
        expectEvent(await approve.call(this, owner, spender, amount), 'Approval', {
          owner: owner,
          spender: spender,
          value: '115792089237316195423570985008687907853269984665640564039457584007913129639935',
        });
      });

      describe('when there was no approved amount before', function () {
        it('approves the requested amount', async function () {
          await approve.call(this, owner, spender, amount);

          // expect(await this.token.allowance(owner, spender)).to.be.bignumber.equal(amount);
          expect(await this.token.allowance(owner, spender)).to.be.bignumber.equal('115792089237316195423570985008687907853269984665640564039457584007913129639935');
        });
      });

      describe('when the spender had an approved amount', function () {
        beforeEach(async function () {
          await approve.call(this, owner, spender, new BN(1));
        });

        it('approves the requested amount and replaces the previous one', async function () {
          await approve.call(this, owner, spender, amount);

          // expect(await this.token.allowance(owner, spender)).to.be.bignumber.equal(amount);
          expect(await this.token.allowance(owner, spender)).to.be.bignumber.equal('115792089237316195423570985008687907853269984665640564039457584007913129639935');
        });
      });
    });
  });

  // describe('when the spender is the zero address', function () {
  //   it('reverts', async function () {
  //     await expectRevert(
  //       approve.call(this, owner, ZERO_ADDRESS, supply),
  //       `${errorPrefix}: approve to the zero address`,
  //     );
  //   });
  // });
}

module.exports = {
  shouldBehaveLikeERC20,
  shouldBehaveLikeERC20Transfer,
  shouldBehaveLikeERC20Approve,
};