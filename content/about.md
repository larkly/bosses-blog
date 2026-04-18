---
title: "About"
date: 2026-04-18
type: page
layout: single
avatar: /images/portrait4.jpg
#kicker: "Colophon & about"
tags: [about]
---

I'm **Bosse** and this is my blog. I work with *platform engineering*, spend a lot of time with FLOSS, I consult for companies trying to build better private cloud platforms and developer experiences, and watch in horror the cultural gap between startups that actually ship and big corps that desperately try to.

The site is called **The Yak Shaver** because most days that's the job.

## What is yak shaving?

*Yak shaving* is the programmer's term for the long chain of tangential tasks you have to complete before you can get back to the thing you actually set out to do.

You want to fix a bug. The bug is in a test. The test won't run because the test runner is out of date. Upgrading the test runner requires a newer language version. The newer language version breaks a dependency. The dependency's maintainer moved it to a new host. The new host requires a different auth flow. Four hours later you're reading RFCs about OAuth device codes and you have forgotten entirely what the original bug was.

That is yak shaving. You are shaving a yak.

## Where the term comes from

The phrase came out of the MIT AI Lab. **Carlin Vieri** coined it after watching the *"[Yak Shaving Day](https://en.wiktionary.org/wiki/yak_shaving)"* episode of *Ren & Stimpy*. According to his officemate [Alexandra Samuel](https://www.alexandrasamuel.com/uncategorized/yak-shaving-etymology), he was mid-way through an absurd chain of admin tasks (getting permission, setting up a DHL account, opening a PO) just to overnight a single document, and declared that he was yak shaving.

**Jeremy H. Brown** then wrote the [canonical definition](https://projects.csail.mit.edu/gsb/old-archive/gsb-archive/gsb2000-02-11.html) in a February 2000 email to `all-ai@ai.mit.edu`:

> Yak shaving is what you are doing when you're doing some stupid, fiddly little task that bears no obvious relationship to what you're supposed to be working on, but yet a chain of twelve causal relations links what you're doing to the original meta-task.

The [original Ren & Stimpy joke](https://youtu.be/trXjZ70ab1Q) is that on Yak Shaving Day one shaves a yak for reasons self-evident only to yak shavers. The technical version is the same shape seen from the inside: you do understand. A long chain of tangential fixes has led you, perfectly logically, to a task that has no visible connection to the thing you sat down to do. To you it's inevitable. To anyone looking over your shoulder, you've gone down a rabbit hole so deep they couldn't possibly follow the thread back. And if they tried to, any reasonable person would have given up six yaks ago.

## Why the job is yak shaving

Platform engineering is yak shaving professionalised. Every interesting problem is six problems deep. You don't build a deploy pipeline; you build the thing that builds the thing that builds the pipeline, because the pipeline framework was last updated in 2019 and no longer works with your identity provider, which was chosen because the previous one was sunset by a vendor who was acquired by a cloud provider who changed the auth API on a Tuesday.

Consulting is yak shaving with a stakeholder. The client asked for one thing; the yak is four layers down; the stakeholder would like to know why the yak is relevant.

Startups are yak shaving with no runway. Big corp is yak shaving with process on top. Open source is the same work, except other people get to be grateful for it. And then there's AI coding, where the yak is plausible enough that you only notice that it wasn't real ten commits later, and then you're out of tokens.

## What you'll find here

- **Platform engineering.** Things I've learned building developer platforms, mostly the hard way.
- **Free, Libre Open Source Software (FLOSS).** What's working, what isn't, and why the thing you're frustrated with is probably a governance problem, not a code problem.
- **AI vibe coding.** What actually holds up in production versus what looks good in a demo tweet.
- **Notes from the industry.** Field observations from what I learn working with what I do.
- **Startup vs. big corp.** A running comparison, with as little ~~bitterness~~ smugness as I can manage.
- **Personal stuff.** Things from my life, whatever I feel like writing about.

## AI use

I write the text myself but use AI to clean it up and assist me on formulations or illustrations. If you consider anything on this site as slop then that's on me. And that's perfectly fine.

## Contact

Write to me at `Ym9zc2VAa2x5a2tlbi5jb20=`. I'll probably read it, if you're able to figure out my insane anti-spam riddle. I may even answer it, if I'm not busy brushing yak hairs off my clothes.

I'm on Matrix as `@bosse:matrix.org`, on Bluesky as `@klykken.com`, on Mastodon as `@bosse@social.linux.pizza`, on GitHub as `larkly` and on LinkedIn as `klykken`.

## Colophon

This site runs on a vibecoded Hugo theme called *Lantern*, with three home layouts (column, broadsheet, index), automatic dark mode with a manual override, OKLCH accents, and a tunable reading width. It's set in **Fraunces** (display) and **Source Serif 4** (body), with **JetBrains Mono** for code. The source is FLOSS and you're welcome to use it for any purpose; see the repository for details. The theme was designed with Claude Design and implemented as a Hugo theme with Claude Code while I was making coffee.
