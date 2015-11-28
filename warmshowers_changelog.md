# Warmshowers changelog

## v5.1.0

- migrated all network kit to use PromiseKit
- fixed deleted messages from not being purged
- updated all dependent libraries to latest version

## v5.0.1

- fixed bug in messages where "reply" would compose a message to the signed in user
- fixed bug in search where initial typed in values return no results
- fixed crash on iOS8

## v5.0 (build 550)

- pin clustering
- iPhone 6 & 6+
- introduced mogenerator for handling Core Data models
- new navigation
- messaging

## v3.6 (build 360)

- Some internationalized strings with `NSLocalizedString`
- added mobilephone field (issue #6)
- fixed issue #5 (logout on intermittent internet access)
- fixed issue when dismissing HostInfoViewController immediately after showing 

## v3.5 (build 358)

- updated SVProgressHUD, RHTools, RHManagedObject, AFNetworking
- deprecated DSActivityView
- fixed bug that prevented a user from logging in

## v3.4 (build 351 submitted)

- upgraded rhmanagedobjectcontext
- fixed metric / imperial switch

## v3.3 (build 341 submitted)

- ARC
- Inserted [tableView reloadData] into appearing list views
- Cleaned up icons with rounded corners
- different map views (corner image)