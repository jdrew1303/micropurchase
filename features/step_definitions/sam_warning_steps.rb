Then(/^I should not see a warning about my SAM registration$/) do
  expect(page).not_to have_selector(".auction-alert")
end

Then(/^I should see a warning that my SAM registration is not complete$/) do
  expect(page).to have_selector(".auction-alert")
  expect(page).to have_content('Your DUNS is not registered with SAM')

  expect(page).to have_link('SAM.gov', href: 'https://www.sam.gov/')
  expect(page).to have_link('the SAM.gov status checker', href: 'https://www.sam.gov/sam/helpPage/SAM_Reg_Status_Help_Page.html')
  expect(page).to have_link('entered your DUNS number into your profile', href: edit_user_path(@user))
end

When(/^I collapse the warning about my SAM registration$/) do
  find(:css, '.warning-hide-trigger').click
end

Then(/^I will not see the warning$/) do
  expect(page).not_to have_content("Your DUNS is not registered with SAM*")
  expect(page).not_to have_selector('.warning-hide-trigger')
end

Then(/^I will see a link to expand the warning$/) do
  find(:css, '.warning-show-trigger')
  expect(page).to_not have_selector('.warning-hide-trigger')
end

Then(/^I will see that the warning is still collapsed$/) do
  step "I will see a link to expand the warning"
end

When(/^I click to expand the warning$/) do
  find(:css, '.warning-show-trigger').click
end
