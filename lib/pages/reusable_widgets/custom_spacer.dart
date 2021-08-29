import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_list/pages/reusable_widgets/custom_column.dart';

class CustomSpacer extends ParentDataWidget<CustomColumnParentData> {
  final int flex;

  CustomSpacer({Key key, this.flex = 1, @required Widget child})
      : assert(flex > 0),
        super(key: key, child: child);

  @override
  void applyParentData(RenderObject renderObject) {
    final CustomColumnParentData parentData =
        renderObject.parentData as CustomColumnParentData;

    if (parentData.flex != flex) {
      parentData.flex = flex;
      final AbstractNode targetParent = renderObject.parent;
      if (targetParent is RenderObject) targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => CustomSpacer;
}
