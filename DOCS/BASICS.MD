# AmethystOS Basics

## How AmethystOS works?

AmethystOS is an OS that is pretty atypical in it's way. The best way to imagine it is an OS without a proper kernel but fully modulable. The kernel doesn't do much apart from setting up a main driver slot (the ZIRMngr Plug). 

## Booting process

The boot process is pretty simple and common. This OS only works on BIOS and not UEFI for the moment. Here is a list of what the booting process looks like:

- BOOT L1
  - Setting up the filesystem
  - Loading the BOOT L2 binary file
  - Running the BOOT L2 binary
- BOOT L2
  - Setting up the system and CPU for 32bits
  - Setup paging
  - Setup the ZIRMngr Slot
  - Loading the minimal drivers
  - Run the ZIR:POSTBOOT driver program

## How does the Kernel works?

The kernel doesn't exists, there are only drivers. The ZIR:POSTBOOT driver is used to setup the additionnal drivers and setup the user environnement (if there is one).

## What are Zircon exactly?

Zircon are drivers that have full access to the system. The main idea behind AmethystOS is not the security, but the control. Zircon communicate with each other via basic syscalls managed by the ZIRMngr. 

If you want to create a Posix layer, you can natively! Just create a driver that have interrupts and use this new Zircon as the posix layer. If you want to create a WinAPI, you do the same. 

## What happend if multiple Zircon require the same interrupts

There is a family of Zircon (The ZIR:BRANCH) that are made only for that. These Zircon manage an interrupt and dispatch the request to other Zircon. You can freely create a Zircon to take the control of an interrupt, but the recommended way of setup a Zircon is to do nothing apart from request a ZIR:BRANCH to branch the request.

## That is clearly insecure

Yes, I know. The phylosophy of the OS is to give control to the users and not to limit them. This is not an OS natively made for everyone, but if you want to implement a Posix Layer with all the security feature, you can! Just know that you might have to do additionnal setup (such as modifying the ZIRMngr). Nothing that nerds can't do!

## How can I contribute to the project?

The source code of the project is totally open source. If you want to get it and create a new AmethystOS, you can! 

If you want to help me develop this OS, just send me a PR and I will read it happily but know that I might not merge it. You can create a "AmethystOS+" and contribute together on it if you want, that is now my problem!

## What is the AmethystOS_old on your repository

It was an old version of AmethystOS that I archived. This was still an AmethystOS with a kernel and without the idea to create a Zircon system and I had to restart it entirely.
