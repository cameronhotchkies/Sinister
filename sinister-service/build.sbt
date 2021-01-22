name := """sinister"""
organization := "com.semisafe"

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

scalaVersion := "2.13.4"

libraryDependencies += guice
libraryDependencies += "org.scalatestplus.play" %% "scalatestplus-play" % "5.1.0" % Test

val circeVersion = "0.12.3"

libraryDependencies ++= Seq(
  "io.circe" %% "circe-core",
  "io.circe" %% "circe-generic",
  "io.circe" %% "circe-parser"
).map(_ % circeVersion)

libraryDependencies += "io.circe" %% "circe-generic-extras" % "0.13.0"
libraryDependencies += "com.dripower" %% "play-circe" % "2812.0"
// Adds additional packages into Twirl
//TwirlKeys.templateImports += "com.semisafe.controllers._"

// Adds additional packages into conf/routes
// play.sbt.routes.RoutesKeys.routesImport += "com.semisafe.binders._"

/******************************************************************************
*                                Code Style                                   *
*******************************************************************************/

// Code style is enforced by the IDE. Do not enable it on build

/******************************************************************************
*                               Code Coverage                                 *
*******************************************************************************/

// Required for IntelliJ IDEA to not complain about the scoverage plugin
libraryDependencies += "org.scoverage" %% "scalac-scoverage-runtime" % "1.4.2" % Test

coverageExcludedPackages := """.*Reverse.*Controller;controllers\..*Reverse.*;router.Routes.*;"""

coverageMinimum := 80
coverageFailOnMinimum := true


/******************************************************************************
*                              Test Environment                               *
*******************************************************************************/

// This will block any tests from overriding the env file, if running in a CI
// environment, ensure this test.env file is overwritten
Test / envFileName := "test.env"
envVars in Test := (envFromFile in Test).value
