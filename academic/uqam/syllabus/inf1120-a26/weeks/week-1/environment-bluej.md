# INF1120 — BlueJ Java environment

Status: recommended course-compatible development environment  
Snapshot: `2026-09-08`

## Contract

The supplied INF1120 material requires a Java development environment on the student computer. The Week 1 introduction shows the Java execution path (`.java` source → Java compiler → `.class` bytecode → JVM → machine execution) and identifies BlueJ as the Java IDE. The current course plan also lists **Environnement Java** in the course content.

## Recommended baseline

- **IDE:** BlueJ `6.0.1` (released 2026-09-04).
- **Java:** JDK `21` LTS.
- **JavaFX:** OpenJFX `21` when using BlueJ's generic installer.
- **Course language:** Java. BlueJ 6.x also supports Kotlin, but Kotlin is outside INF1120 unless the instructor explicitly introduces it.
- **Parity rule:** use BlueJ as the primary lab/instructor-parity environment. `javac` / `java` are secondary verification surfaces, not replacements for BlueJ-specific course behavior.

BlueJ 5.4.0+ requires Java 21 and OpenJFX 21 for the generic installer. Supported Windows/macOS/Debian/Ubuntu BlueJ installers generally include the matching JDK. The upstream current release is 6.0.1.

## Arch Linux primary host

BlueJ does not publish a native Arch package. Prefer the upstream generic installer rather than the currently stale AUR `bluej` package.

Install the versioned JDK:

```sh
sudo pacman -S --needed jdk21-openjdk
```

Verify the explicit toolchain:

```sh
/usr/lib/jvm/java-21-openjdk/bin/java -version
/usr/lib/jvm/java-21-openjdk/bin/javac -version
```

Both should report Java 21.x. Do not change Arch's global Java default unless another workflow actually requires it; BlueJ can be installed and launched with an explicit JDK path.

Acquire the **OpenJFX 21 SDK** from Gluon and unpack it to a stable user-owned path, for example:

```text
~/.local/opt/javafx-sdk-21/
```

Download the current generic BlueJ installer from upstream and launch it explicitly with Java 21:

```sh
/usr/lib/jvm/java-21-openjdk/bin/java -jar ~/Downloads/bluej-*.jar
```

Installer selections:

```text
JDK:        /usr/lib/jvm/java-21-openjdk
JavaFX SDK: ~/.local/opt/javafx-sdk-21
BlueJ:      ~/.local/opt/bluej/
```

## Verification contract

A valid INF1120 environment satisfies all of these:

- BlueJ starts without a missing-JDK or missing-JavaFX prompt.
- BlueJ uses Java 21.
- A new BlueJ project can create and edit a Java class.
- Compilation succeeds and produces `.class` bytecode.
- The same trivial class can be sanity-checked with JDK 21 `javac` / `java` if required.
- Maven, Gradle, preview language features, alternate languages, and third-party frameworks are not required unless a later course artifact explicitly introduces them.

## Operational policy

- Pin this course environment to Java 21 for the term; do not follow Arch's unversioned `jdk-openjdk` package to newer Java releases for INF1120.
- Prefer upstream BlueJ releases while the AUR package lags upstream.
- Preserve projects as ordinary BlueJ/Java source trees and keep backups; the course plan explicitly states that file loss is not accepted as a reason for late or missing work.
- Course-specific Java style/correction rules in this syllabus remain authoritative over generic IDE defaults.

## Evidence

Course material:

- `Slides-Introduction_v1.0.pdf` — Java/JVM execution and BlueJ definition.
- `INF1120_A26_planDeCours.pdf` — Java development environment requirement and course content.

Upstream references:

- https://www.bluej.org/
- https://www.bluej.org/versions.html
- https://www.bluej.org/generic-installation-instructions.html
- https://archlinux.org/packages/extra/x86_64/jdk21-openjdk/
