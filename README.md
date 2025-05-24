# Chatwoot – Customized Fork for Project Assessment

## 🎯 Project Overview

This is a customized fork of [Chatwoot](https://github.com/chatwoot/chatwoot) for a feature assessment project.

* Rebranded with custom logo and color scheme
* Renamed "Captain" → "AI Agent", "Assistant" → "Topic"
* Added `contentAttributes` support in conversation payloads
* Enhanced UI and developer experience


## 🛠 Setup Guide

### 1. Prerequisites

| Tool       | Version             | Install Command                                                                                   |
| ---------- | ------------------- | ------------------------------------------------------------------------------------------------- |
| Homebrew   | Latest              | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh")` |
| Ruby       | 3.4.4 (via `rbenv`) | `brew install rbenv ruby-build` then `rbenv install 3.4.4`                                        |
| Node.js    | 20.x                | `brew install node`                                                                               |
| pnpm       | 10.11.0             | `npm install -g pnpm`                                                                             |
| PostgreSQL | 14                  | `brew install postgresql@14`                                                                      |
| Redis      | latest              | `brew install redis`                                                                              |
| Overmind   | latest              | `brew install tmux overmind`                                                                      |

### 2. Backend Setup

```bash
rbenv global 3.4.4
bundle install
cp .env.example .env
# Edit .env:
#   REDIS_URL=redis://localhost:6379
#   POSTGRES_HOST=localhost
bundle exec rails secret # generate and add to SECRET_KEY_BASE
brew install pgvector
brew services restart postgresql@14
bundle exec rake db:setup
```

### 3. Frontend Setup

```bash
pnpm install
pnpm dev
```

App runs at:

* Frontend (Vite): [http://localhost:3036](http://localhost:3036)
* Backend (Rails): [http://localhost:3000](http://localhost:3000)

### 4. Admin Access (if Signup is disabled)

```bash
pnpm exec rails c
```

```ruby
user = User.new(name: 'Test', email: 'test@example.com', password: 'Test@1234', password_confirmation: 'Test@1234', confirmed_at: Time.now)
user.skip_confirmation!
user.save!
account = Account.create!(name: 'Test Account')
AccountUser.create!(account: account, user: user, role: :administrator)
```

---

## 🧪 Testing & QA

* Login at `http://localhost:3000/app/login`
* Create inbox → Website → Complete setup
* Widget script confirms inbox flow works

---

## 🔧 Features Implemented

### Custom Branding

* New logo and color palette
* Renamed all UI, routes, and labels:

  * Captain → AI Agent
  * Assistant → Topic

### Enhanced Conversations

* `contentAttributes` now supported in payload
* Custom fields (e.g., tags, urgency, mood) embedded and rendered in UI

---

## 📸 UI Screenshots

> Add before/after screenshots to visualize branding changes

---

## 🎥 Demo Video

📽 [Watch the Feature Walkthrough](https://loom.com/your-link-here)

---

## 📂 Repo Structure Changes

* `Captain` and `Assistant` folders/files renamed
* Routes updated in `routes.rb`, views, and frontend components

---

