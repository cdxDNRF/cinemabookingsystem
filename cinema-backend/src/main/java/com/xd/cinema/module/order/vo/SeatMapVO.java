package com.xd.cinema.module.order.vo;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class SeatMapVO {
  private int rows;
  private int cols;
  private List<List<Integer>> grid;
}

