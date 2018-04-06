# License

By making a contribution to this project, I certify that: (a) The contribution was created in whole or in part by me and I have the right to submit it under the open source license indicated in the file; or

(b) The contribution is based upon previous work that, to the best of my knowledge, is covered under an appropriate open source license and I have the right under that license to
submit that work with modifications, whether created in whole or in part by me, under the same open source license (unless I am permitted to submit under a different license), as Indicated in the file; or

(c) The contribution was provided directly to me by some other person who certified (a), (b) or (c) and I have not modified it.

(d) I understand and agree that this project and the contribution are public and that a record of the contribution (including all personal information I submit with it, including my sign-off) is maintained indefinitely and may be redistributed consistent with this project or the open source license(s) involved.

This project is licensed under the GPL version 2 or later.

Some files are licensed under CC-BY or CC0. Attribution is given in the [Thanks](https://github.com/c172p-team/c172p-detailed/blob/master/Thanks) file.

# Reporting bugs or features

Try to be concise when describing the problem. Add screenshots if they can clearly show that something is wrong.

The `master` branch of this project should be used together with the development version of FlightGear. If you're using a released version, you should mention the version number.

# Fixing a bug or adding a feature

Before you starting creating any patches, make sure you first check the bug or feature hasn't already been reported. See the [issues](https://github.com/c172p-team/c172p-detailed/issues) page.

For the repository containing the texture files for the liveries and instruments (including their .xcf files), visit [c172p-detailed-liveries](https://github.com/gilbertohasnofb/c172p-detailed-liveries).

1. Open an issue describing the bug or the feature that you would like to implement. This is so that we can try to reproduce the bug or discuss the feature.

2. Fork the repository and create a branch called `issue-X` where X is the issue number.

3. Submit a new pull request. Make sure you add to the opening comment the text `Fixes #X` where X is the issue number. This will cause Github to create a reference to the issue and when the PR gets merged, the issue will be automatically closed.

Make sure your branch only contains clean commits. Try to avoid `Merge branch...` commits. If you work on the branch from multiple computers or with multiple users, you should use `git pull --rebase` before you push your locally created commits.

Your commits should tell a story how you fixed a bug or implemented a feature. If you have made a commit and want to fix some small mistakes in it, you can use `git commit --amend`. If you need to clean up your commits history by squashing or removing commits, you should use [interactive rebasing](https://www.atlassian.com/git/tutorials/merging-vs-rebasing). You can rebase using `git rebase -i master` or `git rebase -i HEAD~5` to fix your last 5 commits for example.

Don't try to modify parts of the code that do not fix/implement your bug/feature. This will make it more difficult to do code reviews.

Make sure all files have a license that is compatible with the GPL version 2. Files licensed under the CC-BY and CC0 are okay. Make sure you give attribution by modifying the [Thanks](https://github.com/c172p-team/c172p-detailed/blob/master/Thanks) file.

Try to avoid massive commits that fix multiple issues. Use multiple commits instead. For binary files this advice can be ignored.

Write good commit messages (see below)

Make sure your XML and Nasal code follows the coding style guidelines (see below)

# Writing good commit messages

To make the code reviews easier and help the future maintainers of this project to understand what you did and why, you should write clear commits messages.

Make sure the commit message is at most 72 characters. If necessary, leave the second line blank and write a more detailed explanation messages starting on the third line.

Use the imperative mood. Use words like "Fix" and "Add" instead of "Fixed" and "Added".

Wrap the message manually to 72 characters so that you don't have to manually scroll in order to read them.

Do not end with a period.

See [this blog post](https://chris.beams.io/posts/git-commit/) on how to write good commit messages.

# Coding style guidelines

Use 4 spaces indentation for the XML and Nasal files. For example, to find XML files that contain tabs, execute:

```sh
find . -type f -name "*.xml" -exec grep -HP '\t' {}\;
```

If you think it's necessary to fully reformat an XML, execute:

```sh
XMLLINT_INDENT="    " xmllint --format the-file.xml --output the-file.xml
```

This will also remove any blank lines, so you have to reinsert them manually.

Try to avoid trailing whitespace. You can check this with `git diff --check`.

Use the [Stroustrup](https://en.wikipedia.org/wiki/Indentation_style#Variant:_Stroustrup) indentation style for the curly brackets. Do not emit curly brackets for single statements.

Don't use spaces inside parenthesis, but use them around keywords and operators. Write `if (a == b) {` instead of `if( a ==b){`

Do not commit commented-out code or files that are no longer needed. Remove the code or the files.

Use `maketimer` instead of `settimer`. Systems should be written in JSBSim if possible.

# Creating a release

See the [wiki page "Release process and versioning"](https://github.com/Juanvvc/c172p-detailed/wiki/Release-process-and-versioning) how to do a release.
