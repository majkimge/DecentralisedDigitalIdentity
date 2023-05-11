describe('template spec', () => {
  it('passes', () => {
    cy.visit('localhost:3000')
  })




  /* ==== Test Created with Cypress Studio ==== */
  it('add_accounts', function () {
    /* ==== Generated with Cypress Studio ==== */
    cy.visit('localhost:3000');
    cy.get('#passwordInput').clear();
    cy.get('#passwordInput').type('abc');
    cy.get('#passwordSubmit').click();
    cy.get('#accountInput').clear();
    cy.get('#accountInput').type('admin');
    cy.get('#accountSubmit').click();
    cy.get('#accountInput').click();
    cy.get('#accountInput').clear();
    cy.get('#accountInput').type('user');
    cy.get('#accountSubmit').click();
    cy.get('#accountList > :nth-child(2)').should('be.visible');
    /* ==== End Cypress Studio ==== */
  });

  /* ==== Test Created with Cypress Studio ==== */
  it('retrieve_accounts', function () {
    /* ==== Generated with Cypress Studio ==== */
    cy.visit('localhost:3000');
    cy.get('#passwordInput').clear('a');
    cy.get('#passwordInput').type('abc');
    cy.get('#passwordSubmit').click();
    cy.get(':nth-child(1) > form > :nth-child(1) > input').clear('a');
    cy.get(':nth-child(1) > form > :nth-child(1) > input').type('admin');
    cy.get(':nth-child(2) > input').clear('sport cause bulk economy fade hood loud slot enforce blossom scale glide dinosaur old ten symbol cannon rain place tumble rabbit obscure gold volcano');
    cy.get(':nth-child(2) > input').type('sport cause bulk economy fade hood loud slot enforce blossom scale glide dinosaur old ten symbol cannon rain place tumble rabbit obscure gold volcano');
    cy.get(':nth-child(2) > :nth-child(1) > :nth-child(1) > form > [type="submit"]').click();
    cy.get('li').should('be.visible');
    cy.get('li').should('have.text', 'admin: 0x0452d...');
    cy.get('li').click();
    cy.get(':nth-child(1) > :nth-child(2) > :nth-child(1) > :nth-child(1)').click();
    cy.get('.App-header > :nth-child(1) > :nth-child(2) > :nth-child(1)').click();
    /* ==== End Cypress Studio ==== */
  });


  /* ==== Test Created with Cypress Studio ==== */
  it('submit_commands', function () {
    /* ==== Generated with Cypress Studio ==== */
    cy.visit('localhost:3000');
    cy.get('#passwordInput').clear('a');
    cy.get('#passwordInput').type('abc');
    cy.get('#passwordSubmit').click();
    cy.get('#accountInput').clear('a');
    cy.get('#accountInput').type('admin');
    cy.get('#accountSubmit').click();
    cy.get('#commandInput').click();
    cy.get('#commandInput').click();
    cy.get('#commandInput').click();
    cy.get('#commandSubmit').click();
    /* ==== End Cypress Studio ==== */
    /* ==== Generated with Cypress Studio ==== */
    cy.get('#commandInput').click();
    cy.get('#commandInput').click();
    cy.get('#commandInput').click();
    cy.get('#commandInput').click();
    cy.get(':nth-child(1) > form > :nth-child(1) > input').click();
    cy.get('#commandInput').click();
    cy.get('#commandSubmit').click();
    /* ==== End Cypress Studio ==== */
    /* ==== Generated with Cypress Studio ==== */
    cy.get('#commandInput').click();
    cy.get('#commandInput').click();
    cy.get('#commandInput').click();
    cy.get('#commandInput').click();
    cy.get(':nth-child(1) > form > :nth-child(1) > input').click();
    cy.get('#commandInput').clear();
    cy.get('#commandInput').type('create system front_test as admin');
    cy.get('#commandSubmit').click();
    /* ==== End Cypress Studio ==== */
  });
})