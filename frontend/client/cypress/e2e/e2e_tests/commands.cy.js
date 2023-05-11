describe('template spec', () => {
  it('passes', () => {
    cy.visit('localhost:3000')
  })





  /* ==== Test Created with Cypress Studio ==== */
  it('join_system', function () {
    /* ==== Generated with Cypress Studio ==== */
    cy.visit('localhost:3000');
    cy.get('#passwordInput').clear('a');
    cy.get('#passwordInput').type('abc{enter}');
    cy.get('#accountInput').clear('a');
    cy.get('#accountInput').type('admin{enter}');
    cy.get('#commandInput').click();
    cy.get('#commandInput').click();
    cy.get('#commandInput').click();
    cy.get('#commandInput').clear();
    cy.get('#commandInput').type('join system front_test as admin');
    cy.get('#commandSubmit').click();
    cy.get(':nth-child(2) > svg > [fill="currentColor"] > [fill="#59a14f"]').should('be.visible');
    /* ==== End Cypress Studio ==== */
  });
})