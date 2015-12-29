# Copyright 2015, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "spec_helper"

feature "Managing Books" do

  scenario "No books have been added (e2e)", :e2e do
    visit E2E.url + root_path

    expect(page).to have_content "No books found"
  end

  scenario "Adding a book (e2e)", :e2e do
    visit E2E.url + root_path

    click_link "Add Book"
    within "form.new_book" do
      fill_in "Title", with: "A Tale of Two Cities"
      fill_in "Author", with: "Charles Dickens"
      fill_in "Date Published", with: "1859-04-01"
      fill_in "Description", with: "A novel by Charles Dickens"
      click_button "Save"
    end

    expect(page).to have_content "Added Book"

    book = Book.first
    expect(book.title).to eq "A Tale of Two Cities"
    expect(book.author).to eq "Charles Dickens"
    expect(book.published_on).to eq Time.parse("1859-04-01")
    expect(book.description).to eq "A novel by Charles Dickens"
  end

  scenario "Adding a book with missing fields (e2e)", :e2e do
    visit E2E.url + root_path
    click_link "Add Book"
    within "form.new_book" do
      click_button "Save"
    end

    expect(page).to have_content "Title can't be blank"

    within "form.new_book" do
      fill_in "Title", with: "A Tale of Two Cities"
      click_button "Save"
    end

    expect(Book.first.title).to eq "A Tale of Two Cities"
  end

  scenario "Listing all books (e2e)", :e2e do
    visit E2E.url + root_path

    expect(page).to have_content "A Tale of Two Cities"
    expect(page).to have_content "Charles Dickens"

    expect(page).not_to have_link "More"
  end

  scenario "Deleting a book (e2e)", :e2e do
    visit E2E.url + root_path
    click_link "A Tale of Two Cities"
    click_link "Delete Book"

    expect(page).not_to have_content "A Tale of Two Cities"
  end

end
