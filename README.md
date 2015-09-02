# Ash Github Tools

Ash-Ghtools is an [Ash](https://github.com/BrandonRomano/ash) module that contains collection of utility scripts that help automate using Github.

Currently there's only support for bulk creating labels from config files, but this repository is generically named in hopes that it will be expanded upon in the future.

## Getting Started

#### Install

You're going to have to install [Ash](https://github.com/BrandonRomano/ash) to use this module, as it is tightly coupled to the Ash core.

After you have Ash installed, run either one of these two commands depending on your git clone preference:

- `ash self:install git@github.com:carrot/ash-ghtools.git`
- `ash self:install https://github.com/carrot/ash-ghtools.git`

You can also add the `--global` flag to install globally, or add this to your `Ashmodules` file depending on your preference.

#### Config

For this module you must have an `.ashrc` file.  The `.ashrc` is located in your home directory, and follows the same format as a `.bashrc` file.

Inside of your `.ashrc` file, you'll need to add a Github token with permissions to your repositories you want to work with:

```bash
export GHTOOLS_TOKEN="YOUR_GITHUB_TOKEN_HERE"
```

## Labels

#### Labels Config File

The labels command will load in a label config file into a Github repo.

All label configs are located at `extras/label_configs` in this repo.

You can add your own custom label configs in that directory for your own use.

If you work with a team and have a consistent label config, it might make sense to fork this repo and add your own label config files.  If you're convinced you have a really good label config, feel free to create a PR for it.


Label config files are very simple, and follow the following format, with one label per line:

```
label_name:hex_color
```

An example file would look something like this:

```
blocked:000000
bug:fc2929
```

#### Using the Command

After you have a labels config file you're happy with, using this command is very straight forward.

If I were using the carrots-web label config I would run on the command line:

```bash
ash ghtools:labels carrots-web
```

I would then be prompted to input the repository, and if it were for this repo, I would input:

```
carrot/ash-ghtools
```

After entering this information in, your repository will be populated with the labels as defined in the labels config file.

## License

[MIT](LICENSE.txt)
